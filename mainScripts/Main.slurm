#!/bin/bash
#SBATCH --job-name=uceso_oso
#SBATCH -p cloud
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --cpus-per-task=1
#SBATCH --time=15:00:00
#SBATCH --mail-user=khalid.a.abdulla@gmail.com
#SBATCH --mail-type=ALL

module load MATLAB
matlab -nodisplay -nosplash < Main.m
