[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 30
  ny = 30
  xmin = 0.0
  xmax = 30.0
  ymin = 0.0
  ymax = 30.0
  elem_type = QUAD4
[]

[Variables]
  [./c]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = CrossIC
      x1 = 0.0
      x2 = 30.0
      y1 = 0.0
      y2 = 30.0
    [../]
  [../]

  [./w]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Preconditioning]
active = 'SMP'
  [./PBP]
   type = PBP
   solve_order = 'w c'
   preconditioner = 'AMG ASM'
   off_diag_row = 'c '
   off_diag_column = 'w '
  [../]

  [./SMP]
   type = SMP
   off_diag_row = 'w c'
   off_diag_column = 'c w'
  [../]
[]

[Kernels]
  [./cres]
    type = SplitCHPhys
    variable = c
    Ef_name = Ef
    kappa_name = kappa
    w = w
  [../]

  [./wres]
    type = SplitCHWRes
    variable = w
    mob_name = M
  [../]

  [./time]
    type = CoupledImplicitEuler
    variable = w
    v = c
  [../]
[]

[BCs]
  [./Periodic]
    [./top_bottom]
      primary = 0
      secondary = 2
      translation = '0 30.0 0'
    [../]

    [./left_right]
      primary = 1
      secondary = 3
      translation = '-30.0 0 0'
    [../]
  [../]
[]

[Materials]
  [./constant]
    type = GenericConstantMaterial
    block = 0
    prop_names  = 'M Ef  kappa kT'
    prop_values = '1 0.1 1     1e-4'
  [../]
[]

[Executioner]
  type = Transient
  scheme = 'BDF2'

  #Preconditioned JFNK (default)
  solve_type = 'PJFNK'

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  l_max_its = 30
  l_tol = 1.0e-3

  nl_max_its = 50
  nl_rel_tol = 1.0e-10

  dt = 0.1
  num_steps = 2
[]

[Outputs]
  output_initial = true
  exodus = true
  print_linear_residuals = true
  print_perf_log = true
[]
