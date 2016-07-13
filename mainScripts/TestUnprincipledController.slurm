#!/bin/bash
#SBATCH --job-name=test_uceso
#SBATCH -p cloud
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=1
#SBATCH --time=20:00:00
#SBATCH --mail-user=khalid.a.abdulla@gmail.com
#SBATCH --mail-type=ALL

module load MATLAB
matlab -nodisplay -nosplash < TestUnprincipledController.m
