# Copyright 2023 Max Planck Institute for Software Systems, and
# National University of Singapore
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
import itertools
import os
import typing as tp

import simbricks.orchestration.experiments as exp
import simbricks.orchestration.nodeconfig as node
import simbricks.orchestration.simulators as sim
from simbricks.orchestration.nodeconfig import NodeConfig


class JpegAppConfig(node.AppConfig):

    def __init__(self) -> None:
        super().__init__()
        self.pci_dev_id = 0
        self.images: list[str] = []
        self.sw = False

    def prepare_pre_cp(self) -> tp.List[str]:
        cmds = super().prepare_pre_cp()
        cmds.extend([
            'mount -t proc proc /proc',
            'mount -t sysfs sysfs /sys',
            'echo 1 >/sys/module/vfio/parameters/enable_unsafe_noiommu_mode',
            'echo "dead beef" >/sys/bus/pci/drivers/vfio-pci/new_id',
        ])
        return cmds

    def run_cmds(self, node: NodeConfig) -> tp.List[str]:
        cmds = super().run_cmds(node)

        if not self.images:
            raise RuntimeError("No images to be decoded")

        img_paths_sim = []
        for img in self.images:
            img_paths_sim.append(f"/tmp/guest/{os.path.basename(img)}")

        imgs_arg = " ".join(img_paths_sim)
        pci_dev = f"0000:00:{(self.pci_dev_id):02x}.0"
        mode = "sw" if self.sw else "vfio"
        cmds.append(f"/tmp/guest/jpeg_driver {mode} {pci_dev} 0 {imgs_arg}")
        return cmds

    def config_files(self) -> tp.Dict[str, tp.IO]:
        files = {
            'jpeg_driver':
                open('../sims/external/jpeg/src_sw/jpeg_driver', 'rb')
        }

        for img in self.images:
            files[os.path.basename(img)] = open(img, 'rb')

        return files


class JpegNodeConfig(node.NodeConfig):

    def __init__(self):
        super().__init__()
        self.memory = 4 * 1024
        self.kcmd_append = "cma=512M"

    def prepare_pre_cp(self):
        cmds = super().prepare_pre_cp()
        dmabuf_size = 4096 * 4096 * 3 * 2 * 4
        cmds.append(f"modprobe --first-time u-dma-buf udmabuf0={dmabuf_size}")
        return cmds


experiments: tp.List[exp.Experiment] = []

host_variants = ["gt", "gk", "ga"]
modes = ["hw", "sw"]
rtl_variants = [sim.JpegDecoderDev.Variant.RTL]
jpeg_clk_freq_opts = [100, 200]
core_opts = [1, 4]
trace_opts = [mode for mode in sim.VtaVerilatorDev.TraceOpts]
sampling_len_opts = [10, 100]

for (
    host_var,
    mode,
    jpeg_clk_freq,
    cores,
    rtl_variant,
    trace_mode,
    sampling_len,
) in itertools.product(
    host_variants,
    modes,
    jpeg_clk_freq_opts,
    core_opts,
    rtl_variants,
    trace_opts,
    sampling_len_opts,
):
    experiment = exp.Experiment(
        f"jpeg-{host_var}-{mode}-{cores}-{jpeg_clk_freq}-{rtl_variant.value}-{trace_mode.value}{sampling_len}"
    )

    pci_jpeg_id = 2
    sync = False
    if host_var == "qk":
        HostClass = sim.QemuHost
    elif host_var == "qt":
        HostClass = sim.QemuIcountHost
        sync = True
    elif host_var == "gt":
        pci_jpeg_id = 0
        HostClass = sim.Gem5Host
        experiment.checkpoint = True
        sync = True
    elif host_var == "ga":
        pci_jpeg_id = 3

        class CustomGem5ArmHost(sim.Gem5ArmHost):

            def __init__(self, node_config: sim.NodeConfig) -> None:
                super().__init__(node_config)
                self.cpu_freq = "2000MHz"
                self.cpu_type = "hpi_a53"
                self.variant = "opt"
                self.mem_type = "DDR4_2400_16x4"
                self.mem_channels = 4
                # self.extra_main_args.append("--debug-flags=SimBricksPci")

        HostClass = CustomGem5ArmHost
        experiment.checkpoint = True
        sync = True
    elif host_var == "gk":
        pci_jpeg_id = 0
        HostClass = sim.Gem5KvmHost
        sync = False
    elif host_var == "simics":
        HostClass = sim.SimicsHost
        pci_jpeg_id = 0x0B

    # Instantiate server
    server_cfg = JpegNodeConfig()
    # server_cfg.nockp = True
    server_cfg.cores = cores
    if host_var == "simics":
        server_cfg.disk_image += "-simics"
        server_cfg.kcmd_append = ""
    server_cfg.app = JpegAppConfig()
    if host_var in ["gt", "ga"]:
        server_cfg.app.env_simulator = "gem5"
    server_cfg.app.pci_dev_id = pci_jpeg_id
    server_cfg.app.images = [
        '../sims/external/jpeg/images/1024x1024.jpg',
        '../sims/misc/jpeg_decoder/test_img/444_opt/8.jpg',
        '../sims/misc/jpeg_decoder/test_img/444_opt/39.jpg',
    ]
    server_cfg.app.sw = mode == "sw"
    # server_cfg.app.trace = trace_mode.is_trace()
    server = HostClass(server_cfg)
    # Whether to synchronize JPEG accelerator and server
    server.sync = sync
    # Wait until server exits
    server.wait = True

    # Instantiate and connect JPEG PCIe-based accelerator to server
    sampling_period = 1 * 10**6
    jpeg_dec = sim.JpegDecoderDev(
        "jpeg",
        rtl_variant,
        jpeg_clk_freq,
        trace_mode,
        sampling_period,
        sampling_period * sampling_len // 100,
    )
    server.add_pcidev(jpeg_dec)
    if host_var == "simics":
        server.debug_messages = False
        server.start_ts = jpeg_dec.start_tick = int(63 * 10**12)

    server.pci_latency = server.sync_period = jpeg_dec.pci_latency = jpeg_dec.sync_period = 65

    # Add both simulators to experiment
    experiment.add_host(server)
    experiment.add_pcidev(jpeg_dec)

    experiments.append(experiment)
