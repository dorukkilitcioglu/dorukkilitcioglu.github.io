module load cuda/9.0.176
module load cudnn/9.0v7.0.5
module load anaconda3/4.3.1
export PATH=$PATH:$HOME/tools/bin

export RMATE_HOST=localhost
export RMATE_PORT=<rmate_port>

function pygpu {
    RUN_DIR=`pwd`
    cp $HOME/tools/batch/run-gpu-py.sbatch $RUN_DIR/run-gpu-py.sbatch
    echo $1 >> $RUN_DIR/run-gpu-py.sbatch
    sbatch $RUN_DIR/run-gpu-py.sbatch
    rm $RUN_DIR/run-gpu-py.sbatch
}

function gpu {
    RUN_DIR=`pwd`
    cp $HOME/tools/batch/run-gpu.sbatch $RUN_DIR/run-gpu.sbatch
    echo $@ >> $RUN_DIR/run-gpu.sbatch
    sbatch $RUN_DIR/run-gpu.sbatch
    rm $RUN_DIR/run-gpu.sbatch
}

alias jp='sbatch $HOME/tools/batch/run-jupyter.sbatch'
alias sq='squeue -u <net_id>'
alias sr='srun -t5:00:00 --mem=30000 --gres=gpu:1 --pty /bin/bash'