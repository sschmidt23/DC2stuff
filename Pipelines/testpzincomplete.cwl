#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

inputs:
  Tophat_Filter_Fluxes: File
  ugrizy_Mags_Errs: File
  Mstar_SFR: File
  NewSED: File

outputs:
  PDF:
    type: File
    outputSource: PZMainAlgorithm/PDF
  p(z,a):
    type: File
    outputSource: PZMainAlgorithm/PDF2D

steps:
  MakeSpectra:
    in:
      Tophat_Filter_Fluxes: Tophat_Filter_Fluxes
    out:
      [NewSED]

  AddEmissionLines:
    in:
      NewSED: MakeSpectra/NewSED
      ugrizy_Mags_Errs: ugrizy_Mags_Errs
    out:
      [EmLineSED,
      Emline_ugrizy_fluxes]
  
  PZGalaxyGenerator:
    in:
      EmLineSED: AddEmissionLines/EmLineSED
      Mstar_SFR: Mstar_SFR
    out: 
      [PZIncomplete]

  SZCatalogSelection:
    in:
      PZIncomplete: PZGalaxyGenerator/PZIncomplete
    out:
      [SZTrainingSample,
      SZValidationSample]

  ComputePrior:
    in:
      SZTrainingSample: PZGalaxyGenerator/SZTrainingSample
      SZValidationSample_results: PZMainAlgorithm/SZValidationSample_results
    out:
      [Trained_Prior]

  PZMainAlgorithm:
    in: 
      SZTrainingSample: PZGalaxyGenerator/SZTrainingSample
      SZValidationSample: PZGalaxyGenerator/SZValidationSample
      Trained_Prior: ComputePrior/Trained_Prior
      Emline_ugrizy_fluxes: AddEmissionLines/Emline_ugrizy_fluxes
    out:
      [PDF,
      PDF2D,
      SZValidationSample_results]

  PZStorage1D:
    in:
      PDF: PZMainAlgorithm/PDF
    out:
      [Parameterized_PDF]

  PZStorage2D:
    in: 
      PDF2D: PZMainAlgorithm/PDF2D
    out:
      [Parameterized_PDF2D]

  DatabaseIngest:
    in:
      Parameterized_PDF2D: PZStorage2D/Parameterized_PDF2D
      Parameterized_PDF: PZStorage1D/Parameterized_PDF
    out:
      [PZPDF_Database]