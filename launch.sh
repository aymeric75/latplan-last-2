#!/bin/bash







# ###############################
# ###############################

# ## PUZZLE MNIST
# #SBATCH --error=myJobMeta_mnist_without_052SEED1N22moreSAEweight.err
# #SBATCH --output=myJobMeta_mnist_without_052SEED1N22moreSAEweight.out
# task="puzzle"
# type="mnist"
# width_height="3 3"
# nb_examples="5000"
# #suffix="with" # = with author's weight, no noisy test init/goal
# suffix="without" # = without author's weight, no noisy test init/goal
# # suffix="noisywith"
# # suffix="noisywithout"
# baselabel="mnist_"$suffix
# after_sample="puzzle_mnist_3_3_5000_CubeSpaceAE_AMA4Conv_kltune2"
# pb_subdir="puzzle-mnist-3-3"

# conf_folder="05-06T11:21:55.052"
# #conf_folder="05-06T11:21:55.052SEED1INVSDIFFSEED"
# #conf_folder="05-06T11:21:55.052SEED1INVSSAMESEED"
# #conf_folder="05-06T11:21:55.052SEED1"

# # SEED1 = 42, SEED2 = 43
# label=mnist_without_052
# #label=mnist_without_052SEED1BIS
# #label=mnist_without_052SEED1N22

# ##############################################
# ##############################################



# ###############################
# ###############################

# ## BLOCKSWORLD

# exec 1>myblocks_877.out 2>myblocks_877.err

# task="blocks"
# type="cylinders-4-flat"
# width_height=""
# nb_examples="20000"
# #suffix="with" # = with author's weight, no noisy test init/goal
# suffix="without" # = without author's weight, no noisy test init/goal
# # suffix="noisywith"
# # suffix="noisywithout"
# baselabel="mnist_"$suffix
# after_sample="puzzle_mnist_3_3_5000_CubeSpaceAE_AMA4Conv_kltune2"
# pb_subdir="puzzle-mnist-3-3"

# conf_folder="05-06T11:28:54.877"
# #conf_folder="05-06T11:21:55.052SEED1INVSDIFFSEED"
# #conf_folder="05-06T11:21:55.052SEED1INVSSAMESEED"
# #conf_folder="05-06T11:21:55.052SEED1"

# # SEED1 = 42, SEED2 = 43
# label="blocks_877"
# #label=mnist_without_052SEED1BIS
# #label=mnist_without_052SEED1N22

# ##############################################
# ##############################################



###############################
###############################

## SOKOBAN

exec 1>mysokoban_372.out 2>mysokoban_372.err

task="sokoban"
type="sokoban_image-20000-global-global-2-train"
width_height=""
nb_examples="20000"
#suffix="with" # = with author's weight, no noisy test init/goal
suffix="without" # = without author's weight, no noisy test init/goal
# suffix="noisywith"
# suffix="noisywithout"
baselabel="mnist_"$suffix
after_sample="puzzle_mnist_3_3_5000_CubeSpaceAE_AMA4Conv_kltune2"
pb_subdir="puzzle-mnist-3-3"

conf_folder="05-09T16:42:26.372"


# SEED1 = 42, SEED2 = 43
label="sokoban_372"


##############################################
##############################################



pwdd=$(pwd)

problem_file="ama3_samples_${after_sample}_logs_${conf_folder}_domain_blind_problem.pddl"
domain_dir=samples/$after_sample/logs/$conf_folder
domain_file=$domain_dir/domain.pddl

problems_dir=problem-generators/backup-propositional/vanilla/$pb_subdir
#problems_dir=problem-generators/vanilla/$pb_subdir # for noisy images


loadweights="False"
nbepochs="2000"
numstep="2"
moduloepoch="400"

start_epoch="0"
resumee="False"


# # 
# problem-generators/generate-propositional.py 7 20 puzzle mnist 3 3
# exit 0

./train_kltune.py learn $task $type $width_height $nb_examples CubeSpaceAE_AMA4Conv kltune2 --hash $conf_folder
exit 0

# #generate csvs
# ./train_kltune.py dump $task $type $width_height $nb_examples CubeSpaceAE_AMA4Conv kltune2 --hash $conf_folder

# #generate domain.pddl
# ./pddl-ama3.sh $pwdd/$domain_dir

# exit 0


generate_problems() {
    echo $current_problems_dir
    
    ./ama3-planner-all.py $domain_file $current_problems_dir blind 1
}



reformat_domain_last() {
    cd ./downward/src/translate
    python main.py $pwdd/$domain_file $pwdd/$current_problems_dir/$problem_file --operation='remove_duplicates'
    cd $pwdd
}



reformat_problem() {
    cd ./downward/src/translate
    python main.py $pwdd/$domain_file $pwdd/$current_problems_dir/$problem_file --operation='remove_not_from_prob'
    cd $pwdd
}

generate_sas() {
    cd $pwdd/downward/src/translate/
    ### Generate SAS file
    OUTPUT=$(python translate.py $pwdd/$domain_file $pwdd/$current_problems_dir/$problem_file --sas-file output_$label.sas)
    cd $pwdd
}



# loop over all the problem dirs, generate the pb.pddl and if
# plan is found then generate sas from it
loop_for_sas_gen() {

    ./clean-problems.sh

    # generate one problem (used for domain generation)
    ./ama3-planner.py $domain_file $problems_dir/007-000 blind 1


    # finish reformating the domain
    current_problems_dir=$problems_dir/007-000 # for reformat_domain_last
    reformat_domain_last

    ./clean-problems.sh

    current_problems_dir=$problems_dir # generate_problems
    generate_problems

}

problems_dir=problem-generators/backup-propositional/vanilla/puzzle-mnist-3-3
#problems_dir=problem-generators/backup-propositional/vanilla/puzzle-mnist-3-3DIFF
#problems_dir=vanilla/puzzle-mnist-3-3BIS
echo "problems_dir: $problems_dir"
echo "current_problems_dir : $current_problems_dir"

loop_for_sas_gen
exit 0

# #./clean-problems.sh
# current_problems_dir=$problems_dir # generate_problems
# generate_problems

 

# current_problems_dir=problem-generators/backup-propositional/vanilla/puzzle-mnist-3-3/014-005

# problem_file="ama3_samples_puzzle_mnist_3_3_5000_CubeSpaceAE_AMA4Conv_kltune2_logs_05-06T11:21:55.052SEED1N22_domain_blind_problem.pddl"

# generate_sas