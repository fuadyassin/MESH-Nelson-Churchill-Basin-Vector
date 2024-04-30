#!/bin/bash
#SBATCH --account=rpp-kshook
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=8G
#SBATCH --time=6:00:00
#SBATCH --job-name=Brun
#SBATCH --mail-user=fuad.yassin@usask.ca
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

module load cdo
# for field in DRAINSNO DRAINSOL LQWSSNO OVRFLW PREC PRECRN PRECSNO ROF SNO ZSNO QO ET TA
# do
	# cdo -O ensmean /scratch/fuaday/B0_CanRCM4_Runs3/B_Run_noglc_nomgnt/RunxRExIRxBS_r*r*/outRunxRExIRxBS_r*r*_2022_11_19__*/"${field}"_D_GRD.nc "${field}"_D_GRD_ENS.nc 
# done	

# for field in DRAINSNO DRAINSOL LQWSSNO OVRFLW PREC PRECRN PRECSNO ROF SNO ZSNO QO ET TA 
# do
	# cdo -O ensmean /scratch/fuaday/B0_CanRCM4_Runs3/B_Run_noglc_nomgnt/RunxRExIRxBS_r*r*/outRunxRExIRxBS_r*r*_2022_11_19__*/"${field}"_M_GRD.nc "${field}"_M_GRD_ENS.nc 
# done

# for field in DRAINSNO DRAINSOL LQWSSNO OVRFLW PREC PRECRN PRECSNO ROF SNO ZSNO QO ET TA
# do
	# cdo -O ensmean /scratch/fuaday/B0_CanRCM4_Runs3/B_Run_noglc_nomgnt/RunxRExIRxBS_r*r*/outRunxRExIRxBS_r*r*_2022_11_19__*/"${field}"_Y_GRD.nc "${field}"_Y_GRD_ENS.nc 
# done

# cdo -O -L -addc,-273.15 -timmean -selyear,1991/2019 TA_Y_GRD_ENS.nc ebx_ta_ann_sc1.nc 
# cdo -O -L -addc,-273.15 -timmean -selyear,2071/2099 TA_Y_GRD_ENS.nc ebx_ta_ann_sc3.nc
# cdo -O -L -sub ebx_ta_ann_sc1.nc ebx_ta_ann_sc1.nc ebx_ta_ann_diff.nc

# cdo -O -L -timmean -selyear,1991/2019 PREC_Y_GRD_ENS.nc ebx_pr_ann_sc1.nc 
# cdo -O -L -timmean -selyear,2071/2099 PREC_Y_GRD_ENS.nc ebx_pr_ann_sc3.nc
# cdo -O -L -sub ebx_pr_ann_sc1.nc ebx_pr_ann_sc3.nc ebx_pr_ann_diff.nc

# cdo -O -L -timmean -selyear,1991/2019 PRECRN_Y_GRD_ENS.nc ensbx_rain_ann_sc1.nc 
# cdo -O -L -timmean -selyear,2071/2099 PRECRN_Y_GRD_ENS.nc ensbx_rain_ann_sc3.nc
# cdo -O -L -sub ensbx_rain_ann_sc1.nc ensbx_rain_ann_sc3.nc ensbx_rain_ann_diff.nc

# cdo -O -L -timmean -selyear,1991/2019 PRECSNO_Y_GRD_ENS.nc ensbx_snow_ann_sc1.nc 
# cdo -O -L -timmean -selyear,2071/2099 PRECSNO_Y_GRD_ENS.nc ensbx_snow_ann_sc3.nc
# cdo -O -L -sub ensbx_snow_ann_sc1.nc ensbx_snow_ann_sc3.nc ensbx_snow_ann_diff.nc

# cdo -O -L -div ensbx_rain_ann_sc1.nc ebx_pr_ann_sc1.nc ensbx_rain_annFR_sc1.nc 
# cdo -O -L -div ensbx_rain_ann_sc3.nc ebx_pr_ann_sc3.nc ensbx_rain_annFR_sc3.nc
# cdo -O -L -sub ensbx_rain_annFR_sc1.nc ensbx_rain_annFR_sc3.nc ensbx_rain_annFR_diff.nc 

# cdo -O -L -div ensbx_snow_ann_sc1.nc ebx_pr_ann_sc1.nc ensbx_snow_annFR_sc1.nc 
# cdo -O -L -div ensbx_snow_ann_sc3.nc ebx_pr_ann_sc3.nc ensbx_snow_annFR_sc3.nc
# cdo -O -L -sub ensbx_snow_annFR_sc1.nc ensbx_snow_annFR_sc3.nc ensbx_snow_annFR_diff.nc 

# cdo -O -L -timmean -yearmax -selyear,1991/2019 SNO_D_GRD_ENS.nc ensbx_SNO_Ymx_sc1.nc 
# cdo -O -L -timmean -yearmax -selyear,2071/2099 SNO_D_GRD_ENS.nc ensbx_SNO_Ymx_sc3.nc
# cdo -O -L -sub ensbx_SNO_Ymx_sc1.nc ensbx_SNO_Ymx_sc3.nc ensbx_SNO_Ymx_diff.nc

# cdo -O -L -timmean -selyear,1991/2019 SNO_Y_GRD_ENS.nc ensbx_SNO_Y_sc1.nc 
# cdo -O -L -timmean -selyear,2071/2099 SNO_Y_GRD_ENS.nc ensbx_SNO_Y_sc3.nc
# cdo -O -L -sub ensbx_SNO_Y_sc1.nc ensbx_SNO_Y_sc3.nc ensbx_SNO_Y_diff.nc

# cdo -O -L -timmean -yearsum -selyear,1991/2019 ROF_D_GRD_ENS.nc ensbx_ROF_Ysm_sc1.nc 
# cdo -O -L -timmean -yearsum -selyear,2071/2099 ROF_D_GRD_ENS.nc ensbx_ROF_Ysm_sc3.nc
# cdo -O -L -sub ensbx_ROF_Ysm_sc1.nc ensbx_ROF_Ysm_sc3.nc ensbx_ROF_Ysm_diff.nc

cdo -O -L -timmean -yearsum -selmonth,3,4,5 -selyear,1991/2019 ROF_D_GRD_ENS.nc ensbx_ROF_YsmMAM_sc1.nc 
cdo -O -L -timmean -yearsum -selmonth,3,4,5 -selyear,2071/2099 ROF_D_GRD_ENS.nc ensbx_ROF_YsmMAM_sc3.nc
cdo -O -L -sub ensbx_ROF_YsmMAM_sc1.nc ensbx_ROF_YsmMAM_sc3.nc ensbx_ROF_YsmMAM_diff.nc

cdo -O -L -timmean -yearsum -selmonth,6,7,8 -selyear,1991/2019 ROF_D_GRD_ENS.nc ensbx_ROF_YsmJJA_sc1.nc 
cdo -O -L -timmean -yearsum -selmonth,6,7,8 -selyear,2071/2099 ROF_D_GRD_ENS.nc ensbx_ROF_YsmJJA_sc3.nc
cdo -O -L -sub ensbx_ROF_YsmJJA_sc1.nc ensbx_ROF_YsmJJA_sc3.nc ensbx_ROF_YsmJJA_diff.nc

cdo -O -L -selyear,1991/2019 ROF_D_GRD_ENS.nc ensbx_ROF_D_sc1.nc 
cdo -O -L -selyear,2071/2099 ROF_D_GRD_ENS.nc ensbx_ROF_D_sc3.nc

cdo -O -L -selyear,1991/2019 OVRFLW_D_GRD_ENS.nc ensbx_OVRFLW_D_sc1.nc 
cdo -O -L -selyear,2071/2099 OVRFLW_D_GRD_ENS.nc ensbx_OVRFLW_D_sc3.nc

cdo -O -L -selyear,1991/2019 DRAINSNO_D_GRD_ENS.nc ensbx_DRAINSNO_D_sc1.nc 
cdo -O -L -selyear,2071/2099 DRAINSNO_D_GRD_ENS.nc ensbx_DRAINSNO_D_sc3.nc

cdo -O -L -selyear,1991/2019 SNO_D_GRD_ENS.nc ensbx_SNO_D_sc1.nc 
cdo -O -L -selyear,2071/2099 SNO_D_GRD_ENS.nc ensbx_SNO_D_sc3.nc

cdo -O -L -selyear,1991/2019 PRECRN_D_GRD_ENS.nc ensbx_PRECRN_D_sc1.nc 
cdo -O -L -selyear,2071/2099 PRECRN_D_GRD_ENS.nc ensbx_PRECRN_D_sc3.nc


#cdo -O -L -timmean -selyear,1991/2019 QO_Y_GRD_ENS.nc ensbx_QO_Y_sc1.nc 
#cdo -O -L -timmean -selyear,2071/2099 QO_Y_GRD_ENS.nc ensbx_QO_Y_sc3.nc











