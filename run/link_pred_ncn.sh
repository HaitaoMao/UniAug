#!/bin/bash --login
# Uncomment specific block of interest and run
# $ bash script.sh
#
# Specify CUDA devices
# $ CUDA_VISIBLE_DEVICES=1 bash script.sh
#
# To view the generated script without executing, pass the TEST envar as 1
# $ TEST=1 bash script.sh

trap "echo ERROR && exit 1" ERR

# --------------------
export CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-0}
TEST_FLAG=${TEST_FLAG:-0}
AUG_FLAG=${AUG_FLAG:-0}
SEG_FLAG=${SEG_FLAG:-0}
USE_VAL_FLAG=${USE_VAL_FLAG:-0}
REV_DUP_FLAG=${REV_DUP_FLAG:-0}
# --------------------

launch () {
    full_settings=($@)
    cfg_name=${full_settings[0]}
    ckpt_name=${full_settings[1]}
    guidance_type=${full_settings[2]}
    seed=${full_settings[3]}
    thres=${full_settings[4]}
    settings=${full_settings[@]:5}

    extra_args="--thres ${thres} --train_guidance t "
    extra_config=""

    ## predictor
    predictor="ncn"
    # predictor="ncnc"
    
    ## modifying
    # extra_config+="augment.sample.inpaint_every_step=True "
    extra_config+="augment.sample.inpaint_every_step=False "

    ## data
    extra_config+="data.thres=1000 "
    # extra_config+="data.thres=2000 "

    ## training
    extra_config+="train.selection=best "
    # extra_config+="train.selection=last "

    # extra_args+="-pp Ver1 "
    # extra_config+="train.patience=100 "
    # extra_config+="train.eval_steps=1 "

    # extra_config+="train.eval_start=50 "
    # extra_config+="train.patience=50 "

    # extra_args+="--prefix patience-20 "
    # extra_config+="train.patience=20 "

    # extra_args+="--prefix eval_start-300 "
    # extra_config+="train.eval_start=300 "

    # extra_args+="--prefix epochs-100 "
    # extra_config+="train.epochs=100 "

    # extra_args+="--prefix test "
    # extra_config+="augment.guidance_config.num_epochs=10 "

    ## guidance
    # extra_args+="--prefix coef-100 "
    # extra_config+="augment.sample.stability_coef=100 "

    # extra_args+="--prefix step-10.0 "
    # extra_config+="augment.sample.step_size=10.0 "

    # extra_args+="--prefix n_step-10 "
    # extra_config+="augment.sample.num_steps=10 "

    ## combined
    # extra_args+="--prefix coef-100_n_step-10 "
    # extra_config+="augment.sample.stability_coef=100 augment.sample.num_steps=10 "

    # extra_args+="--prefix coef-100_step-10.0 "
    # extra_config+="augment.sample.stability_coef=100 augment.sample.step_size=10.0 "

    # extra_args+="--prefix step-10.0_n_step-10 "
    # extra_config+="augment.sample.step_size=10.0 augment.sample.num_steps=10 "

    # extra_args+="--prefix epochs-100_coef-100 "
    # extra_config+="train.epochs=100 augment.sample.stability_coef=100 "

    # extra_args+="--prefix ep-100_coef-100_step-10.0 "
    # extra_config+="train.epochs=100 augment.sample.stability_coef=100 augment.sample.step_size=10.0 "

    if [[ $USE_VAL_FLAG == 1 ]]; then
        extra_args+="--use_val_edges t "
    fi

    if [[ $REV_DUP_FLAG == 1 ]]; then
        extra_args+="--remove_dup t "
    fi

    if [[ $AUG_FLAG == 1 ]]; then
        extra_args+="--augment t "
        extra_config+="augment.guidance_config.diffusion.guidance_type=${guidance_type} "
        ckpt_path="checkpoints/network_repository/"

        if [[ $SEG_FLAG == 1 ]]; then
            extra_config+="augment.segment_flag=True "
        else
            extra_config+="augment.segment_flag=False "
        fi

        if [[ $ckpt_name == nr_gnn_gt_l4_deg_emb ]]; then
            ckpt_path+="nr_gnn_gt_l4_deg_emb-r.1-Feb21-21:46:19.pth"
        elif [[ $ckpt_name == nr_gnn_gt_l4_deg_lin ]]; then
            ckpt_path+="nr_gnn_gt_l4_deg_lin-r.1-Feb21-21:45:49.pth"

        elif [[ $ckpt_name == full_nr_gnn_gt_l4_dnnm-0_deg_lin_self_guide ]]; then
            ckpt_path+="full_nr_gnn_gt_l4_dnnm-0_deg_lin_self_guide-r.1-Mar08-02:01:14.pth"
        elif [[ $ckpt_name == full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide ]]; then
            ckpt_path+="full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide-r.1-Mar29-21:15:57.pth"
        else
            echo Unknown ckpt name $ckpt_name && exit 1
        fi

        extra_config+="augment.ckpt_path=${ckpt_path} "
    fi

    config_file="config/link_pred_${predictor}/${cfg_name}.yaml"

    script="python link_pred_ncn.py --config ${config_file} --seed ${seed} ${extra_args} ${settings[@]} ${extra_config} "

    echo ${script} && [[ $TEST_FLAG == 0 ]] && eval ${script}
}


# AUG_FLAG=0 USE_VAL_FLAG=1 CUDA_VISIBLE_DEVICES=0 bash run/link_pred_ncn.sh
# AUG_FLAG=1 SEG_FLAG=1 USE_VAL_FLAG=1 CUDA_VISIBLE_DEVICES=0 bash run/link_pred_ncn.sh

# AUG_FLAG=0 CUDA_VISIBLE_DEVICES=0 bash run/link_pred_ncn.sh
# AUG_FLAG=1 SEG_FLAG=1 CUDA_VISIBLE_DEVICES=0 bash run/link_pred_ncn.sh

thres=None
# thres=0.5
# thres=0.6
# thres=0.7
# thres=0.8

# thres=0.9
# thres=0.99
# thres=0.999

# thres=0.9999
# thres=0.99999
# thres=0.999999

# thres=0.9999999
# thres=0.99999999
# thres=0.999999999

# thres=0.9999999999
# thres=0.99999999999
# thres=0.999999999999


echo thres=${thres}

# seeds=(0)

seeds=(0 1 2 3 4 5 6 7 8 9)

# seeds=(0 1 2 3 4)
# seeds=(5 6 7 8 9)

# seeds=(0 1 2 3)
# seeds=(4 5 6 7)
# seeds=(8 9)

# seeds=(0 1 2 3 4 5)
# seeds=(0 1 2)
# seeds=(3 4 5)
# seeds=(6 7)
# seeds=(8 9)

# seeds=(0 1)
# seeds=(2 3)
# seeds=(4 5)
# seeds=(6 7)
# seeds=(8 9)

for seed in ${seeds[@]}; do

echo seed=${seed}

### full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide

## link guidance

# launch cora_link full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide link_pred ${seed} ${thres}& # seg=False
# launch citeseer_link full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide link_pred ${seed} ${thres}& # seg=False
# launch pubmed_link full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide link_pred ${seed} ${thres}&  # seg=2000

launch ogbl-collab_link full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide link_pred ${seed} ${thres}&  # use_val=True
# launch power_link full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide link_pred ${seed} ${thres}&  # seg=False
# launch yst_link full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide link_pred ${seed} ${thres}&  # seg=False
# launch erd_link full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide link_pred ${seed} ${thres}&
# launch photo_link full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide link_pred ${seed} ${thres}&
# launch flickr_link full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide link_pred ${seed} ${thres}&

## node guidance

# launch cora_node full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide node_degree ${seed} ${thres}& # seg=False
# launch citeseer_node full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide node_degree ${seed} ${thres}& # seg=False
# launch pubmed_node full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide node_degree ${seed} ${thres}&

launch ogbl-collab_node full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide node_degree ${seed} ${thres}&  # use_val=True
# launch power_node full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide node_degree ${seed} ${thres}&  # seg=False
# launch yst_node full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide node_degree ${seed} ${thres}&  # seg=False
# launch erd_node full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide node_degree ${seed} ${thres}&
# launch photo_node full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide node_degree ${seed} ${thres}&
# launch flickr_node full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide node_degree ${seed} ${thres}&

## edge guidance

# launch cora_edge full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide edge_cn ${seed} ${thres}& # seg=False
# launch cora_edge full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide edge_aa ${seed} ${thres}& # seg=False
# launch cora_edge full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide edge_katz ${seed} ${thres}& # seg=False

# launch citeseer_edge full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide edge_cn ${seed} ${thres}& # seg=False
# launch citeseer_edge full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide edge_aa ${seed} ${thres}& # seg=False
# launch citeseer_edge full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide edge_katz ${seed} ${thres}& # seg=False

# launch pubmed_edge full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide edge_cn ${seed} ${thres}& # seg=2000
# launch pubmed_edge full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide edge_aa ${seed} ${thres}&  # seg=2000
# launch pubmed_edge full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide edge_katz ${seed} ${thres}&  # seg=2000

# launch ogbl-collab_edge full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide edge_cn ${seed} ${thres}&  # use_val=True
# launch power_edge full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide edge_cn ${seed} ${thres}&  # seg=False
# launch yst_edge full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide edge_cn ${seed} ${thres}&  # seg=False
# launch erd_edge full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide edge_cn ${seed} ${thres}&
# launch photo_edge full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide edge_cn ${seed} ${thres}&
# launch flickr_edge full_nr_github_gnn_gt_l4_dnnm-50_deg_lin_self_guide edge_cn ${seed} ${thres}&


wait

done

# wait