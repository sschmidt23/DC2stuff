#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

inputs:
  pz_pdfs_colors_catalog: File
  specz_calibration_sample_ra_dec_sz: File
  specz_bias_evolution_model: File
  magnification_correction_params: File
  pz_bias_evolution_model: File
  #pz_galaxy_footprint_mask: File
  #specz_galaxy_footprint_mask: File
  pz_galaxy_footprint_randoms: File
  specz_galaxy_footprint_randoms: File
  apparent_magnidute_LF: File
outputs:
  Calibrated_tomographic_Nz:
    type: File
    outputSource: PZClusterz/Calibrated_Tomographic_NZ
  Calibrated_Tomographic_NZ_Covariance:
    type: File
    outputSource: PZClusterz/Calibrated_Tomographic_NZ_Covariance

steps:
  PZTomographicSelector:
    in:
      pz_pdfs_colors_catalog: pz_pdfs_colors_catalog
    out:
      [pz_tomographic_bins_radec_file,
      pz_bias_evolution_model]

  TwoPointCode:
    in:
      pz_tomographic_bins_radec_file: PZTomographicSelector/pz_tomographic_bins_radec_file
      #specz_galaxy_footprint_mask: specz_galaxy_footprint_mask
      specz_galaxy_footprint_randoms: specz_galaxy_footprint_randoms
      #pz_galaxy_footprint_mask: pz_galaxy_footprint_mask
      pz_galaxy_footprint_randoms: pz_galaxy_footprint_randoms
      specz_calibration_sample_ra_dec_sz: specz_calibration_sample_ra_dec_sz
    out:
      [SZPZ_Pairs_or_Corr_Functions]

  PZClusterz:
    in:
      specz_bias_evolution_model: specz_bias_evolution_model
      pz_bias_evolution_model: PZTomographicSelector/pz_bias_evolution_model
      magnification_correction_params: magnification_correction_params
      SZPZ_Pairs_or_Corr_Functions: TwoPointCode/SZPZ_Pairs_or_Corr_Functions
    out:
      [Calibrated_Tomographic_NZ,
       Calibrated_Tomographic_NZ_Covariance]

  MagnificationCorrection:
    in:
      Calibrated_Tomographic_NZ: PZClusterz/Calibrated_Tomographic_NZ
      apparent_magnidute_LF: apparent_magnidute_LF
    out:
      [magnification_correction_params]