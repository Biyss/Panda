[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50
  ny = 25
  nz = 0
  xmax = 50
  ymax = 25
  zmax = 0
  elem_type = QUAD4
[]

[Variables]
  [./c]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = SpecifiedSmoothCircleIC
      invalue = 1.0
      outvalue = 0.0
      int_width = 6.0
      x_positions = '20.0 30.0 '
      z_positions = '0.0 0.0 '
      y_positions = '0.0 25.0 '
      radii = '10.0 10.0'
      3D_spheres = false
      variable = c
      block = 0
    [../]
  [../]
  [./w]
    order = FIRST
    family = LAGRANGE
  [../]
  [./PolycrystalVariables]
    var_name_base = eta
    op_num = 2
  [../]
[]

[AuxVariables]
  [./bnds]
  [../]
  [./vadv00]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vadv10]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vadv0_div]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vadv1_div]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vadv11]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vadv01]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  # active = 'eta0_dot w_res eta1_dot acbulk_eta0 c_res acbulk_eta1 time acint_eta0 acint_eta1'
  [./c_res]
    type = SplitCHParsed
    variable = c
    f_name = F
    kappa_name = kappa_c
    w = w
    args = 'eta0 eta1'
  [../]
  [./w_res]
    type = SplitCHWRes
    variable = w
    mob_name = M
  [../]
  [./time]
    type = CoupledTimeDerivative
    variable = w
    v = c
  [../]
  [./motion]
    type = MultiGrainRigidBodyMotion
    variable = w
    c = c
    advection_velocity = advection_velocity
    advection_velocity_divergence = advection_velocity_divergence
  [../]
  [./eta0_dot]
    type = TimeDerivative
    variable = eta0
  [../]
  [./eta1_dot]
    type = TimeDerivative
    variable = eta1
  [../]
  [./vadv_eta0]
    type = SingleGrainRigidBodyMotion
    variable = eta0
    c = c
    advection_velocity = advection_velocity
    advection_velocity_divergence = advection_velocity_divergence
  [../]
  [./vadv_eta1]
    type = SingleGrainRigidBodyMotion
    variable = eta1
    c = c
    advection_velocity = advection_velocity
    advection_velocity_divergence = advection_velocity_divergence
    op_index = 1
  [../]
  [./acint_eta0]
    type = ACInterface
    variable = eta0
    mob_name = M
    args = 'c eta1'
    kappa_name = kappa_eta
  [../]
  [./acint_eta1]
    type = ACInterface
    variable = eta1
    mob_name = M
    args = 'c eta0'
    kappa_name = kappa_eta
  [../]
  [./acbulk_eta0]
    type = ACParsed
    variable = eta0
    mob_name = M
    f_name = F
    args = 'c eta1'
  [../]
  [./acbulk_eta1]
    type = ACParsed
    variable = eta1
    mob_name = M
    f_name = F
    args = 'c eta0'
  [../]
[]

[AuxKernels]
  [./bnds]
    type = BndsCalcAux
    variable = bnds
    var_name_base = eta
    op_num = 2.0
    v = 'eta0 eta1'
    block = 0
  [../]
  [./vadv00]
    type = MaterialStdVectorRealGradientAux
    variable = vadv00
    property = advection_velocity
  [../]
  [./vadv01]
    type = MaterialStdVectorRealGradientAux
    variable = vadv01
    property = advection_velocity
    component = 1
  [../]
  [./vadv10]
    type = MaterialStdVectorRealGradientAux
    variable = vadv10
    index = 1
    property = advection_velocity
  [../]
  [./vadv11]
    type = MaterialStdVectorRealGradientAux
    variable = vadv11
    index = 1
    component = 1
    property = advection_velocity
  [../]
  [./vadv0_div]
    type = MaterialStdVectorAux
    variable = vadv0_div
    property = advection_velocity_divergence
  [../]
  [./vadv1_div]
    type = MaterialStdVectorAux
    variable = vadv1_div
    index = 1
    property = advection_velocity_divergence
  [../]
[]

[Materials]
  [./pfmobility]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'M    kappa_c  kappa_eta'
    prop_values = '1.0  1.0      0.5'
  [../]
  [./free_energy]
    type = DerivativeParsedMaterial
    block = 0
    args = 'c eta0 eta1'
    constant_names = 'barr_height  cv_eq'
    constant_expressions = '0.1          1.0e-2'
    function = 16*barr_height*(c-cv_eq)^2*(1-cv_eq-c)^2+(c-eta0)^2+(c-eta1)^2
    derivative_order = 2
  [../]
  [./advection_vel]
    type = ConstGrainAdvectionVelocity
    block = 0
    grain_force = grain_force
    etas = 'eta0 eta1'
    grain_data = grain_center
  [../]
[]

[VectorPostprocessors]
  [./centers]
    type = GrainCentersPostprocessor
    grain_data = grain_center
  [../]
  [./forces]
    type = ConstantGrainForcesPostprocessor
    grain_force = grain_force
  [../]
[]

[UserObjects]
  [./grain_center]
    type = ComputeGrainCenterUserObject
    etas = 'eta0 eta1'
    execute_on = 'initial linear'
  [../]
  [./grain_force]
    # force = '1.0 0.5 0.0 '
    type = ConstantGrainForceAndTorque
    execute_on = 'initial linear'
    force = '0.2 0.2 0.0 0.2 -0.2 0.0'
    torque = '0.0 0.0 0.0 0.0  0.0 0.0 '
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  # petsc_options_iname =  '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  # petsc_options_value =  'asm         31   preonly   lu      1'
  type = Transient
  nl_max_its = 30
  scheme = bdf2
  solve_type = PJFNK
  petsc_options_iname = -pc_type
  petsc_options_value = lu
  l_max_its = 30
  l_tol = 1.0e-4
  nl_rel_tol = 1.0e-10
  start_time = 0.0
  dt = 0.1
  num_steps = 100
[]

[Outputs]
  output_initial = true
  exodus = true
  print_perf_log = true
  csv = true
  file_base = torque
[]

[ICs]
  [./ic_eta0]
    int_width = 6.0
    x1 = 20.0
    y1 = 0.0
    radius = 10.0
    outvalue = 0.0
    variable = eta0
    invalue = 1.0
    type = SmoothCircleIC
  [../]
  [./IC_eta1]
    int_width = 6.0
    x1 = 30.0
    y1 = 25.0
    radius = 10.0
    outvalue = 0.0
    variable = eta1
    invalue = 1.0
    type = SmoothCircleIC
  [../]
[]
