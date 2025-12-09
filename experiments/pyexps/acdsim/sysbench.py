import simbricks.orchestration.experiments as exp
import simbricks.orchestration.nodeconfig as node
import simbricks.orchestration.simulators as sim

import itertools


class SysbenchCPU(node.AppConfig):

    def __init__(self, threads: int):
        super().__init__()
        self._threads = threads

    def run_cmds(self, node):
        taskset_cores = ",".join([str(i) for i in range(self._threads)])
        cmd = f"taskset -c {taskset_cores} sysbench --threads={self._threads} --time=2 cpu run"
        return ["m5 resetstats", cmd, "m5 dumpstats"]


class SysbenchMemory(node.AppConfig):

    def __init__(self, threads: int, operation: str, access_mode: str):
        super().__init__()
        self._threads = threads
        self._operation = operation
        self._access_mode = access_mode

    def run_cmds(self, node):
        if self._access_mode == "seq":
            block_size = "1G"
            total_size = "20G"
        else:
            block_size = "512M"
            total_size = "512M"

        taskset_cores = ",".join([str(i) for i in range(self._threads)])
        cmd = f"taskset -c {taskset_cores} sysbench --threads={self._threads} --time=2 --rand-type=uniform --rand-spec-iter=1 memory --memory-block-size={block_size} --memory-total-size={total_size} --memory-oper={self._operation} --memory-access-mode={self._access_mode} run"
        return ["m5 resetstats", cmd]


class CustomGem5ArmHost(sim.Gem5ArmHost):

    def __init__(self, node_config: sim.NodeConfig) -> None:
        super().__init__(node_config)
        self.cpu_freq = "1200MHz"
        self.cpu_type = "hpi_a53"
        self.variant = "fast"
        self.mem_type = "LPDDR4_1066_1x32"


experiments = []
core_opts = [4, 24, 48]
thread_opts = [1, 2, 4, 24, 48]
mem_operations = ["read", "write"]
cpu_configs = itertools.product(["cpu"], core_opts, thread_opts, [""], [""])
mem_configs = itertools.product(
    ["mem"], core_opts, thread_opts, mem_operations, ["seq", "rnd"]
)

for benchmark, cores, threads, operation, access_mode in itertools.chain(
    cpu_configs, mem_configs
):
    # skip invalid configurations
    if threads > cores:
        continue

    e = exp.Experiment(
        f"sysbench-{benchmark}-{cores}-{threads}-{operation}-{access_mode}"
    )
    e.checkpoint = True

    node_cfg = node.NodeConfig()
    node_cfg.cores = cores
    node_cfg.memory = 512 * cores
    if benchmark == "cpu":
        node_cfg.app = SysbenchCPU(threads)
    else:
        node_cfg.app = SysbenchMemory(threads, operation, access_mode)

    host = CustomGem5ArmHost(node_cfg)
    host.wait = True
    e.add_host(host)
    experiments.append(e)
