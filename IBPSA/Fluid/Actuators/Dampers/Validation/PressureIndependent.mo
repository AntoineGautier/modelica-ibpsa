within IBPSA.Fluid.Actuators.Dampers.Validation;
model PressureIndependent
  "Dampers with constant pressure difference and varying control signal."
  extends Modelica.Icons.Example;

  package Medium = IBPSA.Media.Air "Medium model for air";
  parameter Modelica.SIunits.PressureDifference dp_nominal(
    displayUnit="Pa") = 10
    "Damper nominal pressure drop";
  parameter Modelica.SIunits.MassFlowRate m_flow_nominal=1
    "Damper nominal mass flow rate";
  IBPSA.Fluid.Actuators.Dampers.Exponential damExp(
    redeclare final package Medium = Medium,
    use_inputFilter=false,
    final dpDamper_nominal=dp_nominal,
    final m_flow_nominal=m_flow_nominal)
    "A damper with exponential opening characteristics"
    annotation (Placement(transformation(extent={{0,-50},{20,-30}})));
  Modelica.Blocks.Sources.Ramp yRam(
    duration=0.3,
    offset=0,
    startTime=0.3,
    height=1) annotation (Placement(transformation(extent={{-20,70},{0,90}})));
  IBPSA.Fluid.Sources.Boundary_pT sou(
    redeclare final package Medium = Medium,
    use_p_in=true,
    p(displayUnit="Pa") = 101335,
    T=293.15,
    nPorts=4) "Pressure boundary condition"
    annotation (Placement(transformation(extent={{-50,-10},{-30,10}})));
  IBPSA.Fluid.Sources.Boundary_pT sin(
    redeclare final package Medium = Medium,
    nPorts=4) "Pressure boundary condition"
    annotation (Placement(transformation(extent={{102,-10},{82,10}})));
  IBPSA.Fluid.Actuators.Dampers.PressureIndependent damPreInd(
    redeclare final package Medium = Medium,
    final m_flow_nominal=m_flow_nominal,
    final dpDamper_nominal=dp_nominal,
    use_inputFilter=false)
    "A damper with a mass flow proportional to the input signal"
    annotation (Placement(transformation(extent={{0,-10},{20,10}})));
  Exponential damExpPI(
    redeclare final package Medium = Medium,
    use_inputFilter=false,
    final dpDamper_nominal=dp_nominal,
    final m_flow_nominal=m_flow_nominal)
    "A damper with exponential opening characteristics"
    annotation (Placement(transformation(extent={{0,-90},{20,-70}})));
  Controls.Continuous.LimPID conPID(k=10,
    Ti=0.001,
    initType=Modelica.Blocks.Types.InitPID.InitialState)
    "Damper discharge flow rate controller"
    annotation (Placement(transformation(extent={{-70,-70},{-50,-50}})));
  Sensors.MassFlowRate senMasFlo(
    redeclare final package Medium = Medium)
    annotation (Placement(transformation(extent={{30,-70},{50,-90}})));
  Modelica.Blocks.Sources.Ramp yRam1(
    duration=0.3,
    offset=Medium.p_default - 20,
    startTime=0,
    height=40)
    annotation (Placement(transformation(extent={{-90,70},{-70,90}})));
  Modelica.Blocks.Sources.Ramp yRam2(
    duration=0.3,
    offset=0,
    startTime=0.7,
    height=-40)
    annotation (Placement(transformation(extent={{-90,30},{-70,50}})));
  Modelica.Blocks.Math.Add add
    annotation (Placement(transformation(extent={{-52,30},{-32,50}})));
  Sensors.RelativePressure senRelPre(
    redeclare final package Medium = Medium)
    annotation (Placement(transformation(extent={{0,30},{20,50}})));
  Modelica.Blocks.Math.Gain gain(k=1/m_flow_nominal) "Normalize"
    annotation (Placement(transformation(extent={{-20,-110},{-40,-90}})));
equation
  connect(damExp.port_a, sou.ports[1]) annotation (Line(points={{0,-40},{-20,-40},
          {-20,3},{-30,3}}, color={0,127,255}));
  connect(damExp.port_b, sin.ports[1]) annotation (Line(points={{20,-40},{60,
          -40},{60,3},{82,3}},
                          color={0,127,255}));
  connect(sou.ports[2], damPreInd.port_a) annotation (Line(points={{-30,1},{-20,
          1},{-20,0},{0,0}}, color={0,127,255}));
  connect(damPreInd.port_b, sin.ports[2])
    annotation (Line(points={{20,0},{48,0},{48,1},{82,1}}, color={0,127,255}));
  connect(yRam.y, damPreInd.y) annotation (Line(points={{1,80},{40,80},{40,20},{
          10,20},{10,12}}, color={0,0,127}));
  connect(damPreInd.y_actual, damExp.y) annotation (Line(points={{15,7},{40,7},{
          40,-20},{10,-20},{10,-28}}, color={0,0,127}));
  connect(damExpPI.port_b, senMasFlo.port_a)
    annotation (Line(points={{20,-80},{30,-80}}, color={0,127,255}));
  connect(senMasFlo.port_b, sin.ports[3]) annotation (Line(points={{50,-80},{68,
          -80},{68,-1},{82,-1}},             color={0,127,255}));
  connect(sou.ports[3], damExpPI.port_a) annotation (Line(points={{-30,-1},{-20,
          -1},{-20,-80},{0,-80}}, color={0,127,255}));
  connect(conPID.y, damExpPI.y)
    annotation (Line(points={{-49,-60},{10,-60},{10,-68}}, color={0,0,127}));
  connect(yRam.y, conPID.u_s) annotation (Line(points={{1,80},{40,80},{40,100},{
          -100,100},{-100,-60},{-72,-60}},
                                    color={0,0,127}));
  connect(yRam1.y, add.u1) annotation (Line(points={{-69,80},{-60,80},{-60,46},
          {-54,46}}, color={0,0,127}));
  connect(yRam2.y, add.u2) annotation (Line(points={{-69,40},{-60,40},{-60,34},
          {-54,34}}, color={0,0,127}));
  connect(add.y, sou.p_in) annotation (Line(points={{-31,40},{-26,40},{-26,20},{
          -60,20},{-60,8},{-52,8}},  color={0,0,127}));
  connect(sou.ports[4], senRelPre.port_a) annotation (Line(points={{-30,-3},{-20,
          -3},{-20,40},{0,40}}, color={0,127,255}));
  connect(senRelPre.port_b, sin.ports[4]) annotation (Line(points={{20,40},{60,
          40},{60,-3},{82,-3}},
                            color={0,127,255}));
  connect(senMasFlo.m_flow, gain.u)
    annotation (Line(points={{40,-91},{40,-100},{-18,-100}}, color={0,0,127}));
  connect(gain.y, conPID.u_m) annotation (Line(points={{-41,-100},{-60,-100},{-60,
          -72}}, color={0,0,127}));
    annotation (experiment(Tolerance=1e-6, StopTime=1.0),
__Dymola_Commands(
file="modelica://IBPSA/Resources/Scripts/Dymola/Fluid/Actuators/Dampers/Validation/PressureIndependent.mos"
"Simulate and plot"),
Documentation(info="<html>
<p>
Test model for the pressure independent damper model.
</p>
</html>", revisions="<html>
<ul>
<li>
April 5, 2020 by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"),
    Diagram(coordinateSystem(extent={{-120,-120},{120,120}})));
end PressureIndependent;
