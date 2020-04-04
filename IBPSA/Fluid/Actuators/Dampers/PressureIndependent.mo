within IBPSA.Fluid.Actuators.Dampers;
model PressureIndependent
  "Model for an air damper whose mass flow is proportional to the input signal"
  extends IBPSA.Fluid.Actuators.BaseClasses.PartialDamperExponential(
    final linearized=false,
    final casePreInd=true,
    from_dp=true);
  input Real phi = l + y_internal*(1 - l)
    "Ratio actual to nominal mass flow rate of damper, phi=kDam(y)/kDam(y=1)";
  parameter Real l2(unit="1", min=1e-10) = 0.01
    "Gain for mass flow increase if pressure is above nominal pressure"
    annotation(Dialog(tab="Advanced"));
  parameter Real deltax(unit="1", min=1E-5) = 0.02 "Transition interval for flow rate"
    annotation(Dialog(tab="Advanced"));
  parameter Modelica.SIunits.PressureDifference dp_small(displayUnit="Pa")=
    1E-2 * dp_nominal_pos
    "Pressure drop for sizing the transition regions"
    annotation(Dialog(tab="Advanced"));
protected
  parameter Real y_min = 2E-2
    "Minimum value of control signal before zeroing of the opening";
  parameter Integer sizeSupSplBnd = 5
    "Number of support points on each quadratic domain for spline interpolation";
  parameter Integer sizeSupSpl = 2 * sizeSupSplBnd + 3
    "Total number of support points for spline interpolation";
  parameter Real[sizeSupSpl] ySupSpl_raw = cat(
    1,
    linspace(1, yU, sizeSupSplBnd),
    {yU-1/3*(yU-yL), (yU+yL)/2, yU-2/3*(yU-yL)},
    linspace(yL, 0, sizeSupSplBnd))
    "y values of unsorted support points for spline interpolation";
  parameter Real[sizeSupSpl] kSupSpl_raw = IBPSA.Fluid.Actuators.BaseClasses.exponentialDamper(
    y=ySupSpl_raw, a=a, b=b, cL=cL, cU=cU, yL=yL, yU=yU)
    "k values of unsorted support points for spline interpolation";
  parameter Real[sizeSupSpl] ySupSpl(each fixed=false)
    "y values of sorted support points for spline interpolation";
  parameter Real[sizeSupSpl] kSupSpl(each fixed=false)
    "k values of sorted support points for spline interpolation";
  parameter Integer[sizeSupSpl] idx_sorted(each fixed=false)
    "Indexes of sorted support points";
  parameter Real[sizeSupSpl] invSplDer(each fixed=false)
    "Derivatives at support points for spline interpolation";
  parameter Real coeff1 = l2/dpDamper_nominal*m_flow_nominal
    "Parameter for avoiding unnecessary computations";
  parameter Real coeff2 = 1/coeff1
    "Parameter for avoiding unnecessary computations";
  constant Real y2dd = 0
    "Second derivative at second support point";
  Modelica.SIunits.MassFlowRate m_flow_set
    "Requested mass flow rate";
  Modelica.SIunits.PressureDifference dp_min(displayUnit="Pa")
    "Minimum pressure difference required for delivering requested mass flow rate";
  Modelica.SIunits.PressureDifference dp_x, dp_x1, dp_x2, dp_y2, dp_y1
    "Support points for interpolation flow functions";
  Modelica.SIunits.MassFlowRate m_flow_x, m_flow_x1, m_flow_x2, m_flow_y2, m_flow_y1
    "Support points for interpolation flow functions";
  Modelica.SIunits.MassFlowRate m_flow_smooth
    "Smooth interpolation result between two flow regimes";
  Modelica.SIunits.PressureDifference dp_smooth
    "Smooth interpolation result between two flow regimes";
  Real y_actual_smooth(final unit="1")
    "Fractional opening computed based on m_flow_smooth and dp";
initial equation
  (kSupSpl, idx_sorted) = Modelica.Math.Vectors.sort(kSupSpl_raw, ascending=true);
  ySupSpl = ySupSpl_raw[idx_sorted];
  invSplDer = IBPSA.Utilities.Math.Functions.splineDerivatives(x=kSupSpl, y=ySupSpl);
equation
  // From TwoWayPressureIndependent valve model
  m_flow_set = m_flow_nominal*phi;
  dp_min = IBPSA.Fluid.BaseClasses.FlowModels.basicFlowFunction_m_flow(
              m_flow=m_flow_set,
              k=kTotMax,
              m_flow_turbulent=m_flow_turbulent);

  if from_dp then
    m_flow_x=0;
    m_flow_x1=0;
    m_flow_x2=0;
    dp_y1=0;
    dp_y2=0;
    dp_smooth=0;

    dp_x = dp-dp_min;
    dp_x1 = -dp_x2;
    dp_x2 = deltax*dp_min;
    // min function ensures that m_flow_y1 does not increase further for dp_x > dp_x1
    m_flow_y1 = IBPSA.Fluid.BaseClasses.FlowModels.basicFlowFunction_dp(
                                  dp=min(dp, dp_min+dp_x1),
                                  k=kTotMax,
                                  m_flow_turbulent=m_flow_turbulent);
    // max function ensures that m_flow_y2 does not decrease further for dp_x < dp_x2
    m_flow_y2 = m_flow_set + coeff1*max(dp_x,dp_x2);

    m_flow_smooth = noEvent(smooth(2,
        if dp_x <= dp_x1
        then m_flow_y1
        elseif dp_x >=dp_x2
        then m_flow_y2
        else IBPSA.Utilities.Math.Functions.quinticHermite(
                 x=dp_x,
                 x1=dp_x1,
                 x2=dp_x2,
                 y1=m_flow_y1,
                 y2=m_flow_y2,
                 y1d= IBPSA.Fluid.BaseClasses.FlowModels.basicFlowFunction_dp_der(
                                     dp=dp_min + dp_x1,
                                     k=kTotMax,
                                     m_flow_turbulent=m_flow_turbulent,
                                     dp_der=1),
                 y2d=coeff1,
                 y1dd=IBPSA.Fluid.BaseClasses.FlowModels.basicFlowFunction_dp_der2(
                                     dp=dp_min + dp_x1,
                                     k=kTotMax,
                                     m_flow_turbulent=m_flow_turbulent,
                                     dp_der=1,
                                     dp_der2=0),
                 y2dd=y2dd)));
  else
    dp_x=0;
    dp_x1=0;
    dp_x2=0;
    m_flow_y1=0;
    m_flow_y2=0;
    m_flow_smooth=0;

    m_flow_x = m_flow-m_flow_set;
    m_flow_x1 = -m_flow_x2;
    m_flow_x2 = deltax*m_flow_set;
    // min function ensures that dp_y1 does not increase further for m_flow_x > m_flow_x1
    dp_y1 = IBPSA.Fluid.BaseClasses.FlowModels.basicFlowFunction_m_flow(
                                     m_flow=min(m_flow, m_flow_set + m_flow_x1),
                                     k=kTotMax,
                                     m_flow_turbulent=m_flow_turbulent);
    // max function ensures that dp_y2 does not decrease further for m_flow_x < m_flow_x2
    dp_y2 = dp_min + coeff2*max(m_flow_x, m_flow_x2);

    dp_smooth = noEvent(smooth(2,
        if m_flow_x <= m_flow_x1
        then dp_y1
        elseif m_flow_x >=m_flow_x2
        then dp_y2
        else IBPSA.Utilities.Math.Functions.quinticHermite(
                 x=m_flow_x,
                 x1=m_flow_x1,
                 x2=m_flow_x2,
                 y1=dp_y1,
                 y2=dp_y2,
                 y1d=IBPSA.Fluid.BaseClasses.FlowModels.basicFlowFunction_m_flow_der(
                                     m_flow=m_flow_set + m_flow_x1,
                                     k=kTotMax,
                                     m_flow_turbulent=m_flow_turbulent,
                                     m_flow_der=1),
                 y2d=coeff2,
                 y1dd=IBPSA.Fluid.BaseClasses.FlowModels.basicFlowFunction_m_flow_der2(
                                     m_flow=m_flow_set + m_flow_x1,
                                     k=kTotMax,
                                     m_flow_turbulent=m_flow_turbulent,
                                     m_flow_der=1,
                                     m_flow_der2=0),
                 y2dd=y2dd)));
  end if;
  // Computation of damper opening
  k = IBPSA.Fluid.BaseClasses.FlowModels.basicFlowFunction_inv(
    m_flow=m_flow,
    dp=dp,
    m_flow_small=m_flow_small,
    dp_small=dp_small);
  kDam = sqrt(1 / (1 / k^2 - 1 / kFixed^2));
  y_actual_smooth = IBPSA.Utilities.Math.Functions.regStep(
    x=y_internal - y_min,
    y1=IBPSA.Fluid.Actuators.BaseClasses.exponentialDamper_inv(
      kThetaSqRt=sqrt(2*rho)*A/kDam, kSupSpl=kSupSpl, ySupSpl=ySupSpl, invSplDer=invSplDer),
    y2=0,
    x_small=1E-3);
  // Homotopy transformation
  if homotopyInitialization then
    if from_dp then
      m_flow=homotopy(actual=m_flow_smooth,
                      simplified=m_flow_nominal_pos*dp/dp_nominal_pos);
    else
      dp=homotopy(actual=dp_smooth,
                  simplified=dp_nominal_pos*m_flow/m_flow_nominal_pos);
    end if;
    y_actual = homotopy(
      actual=y_actual_smooth,
      simplified=y);
  else
    if from_dp then
      m_flow=m_flow_smooth;
    else
      dp=dp_smooth;
    end if;
    y_actual = y_actual_smooth;
  end if;
annotation (
  defaultComponentName="damPreInd",
  Documentation(info="<html>
<p>
Model for an air damper whose airflow is proportional to the input signal, assuming
that at <code>y = 1</code>, <code>m_flow = m_flow_nominal</code>. This is unless the pressure difference
<code>dp</code> is too low,
in which case a <code>kDam = m_flow_nominal/sqrt(dp_nominal)</code> characteristic is used.
</p>
<p>
The model is similar to
<a href=\"modelica://IBPSA.Fluid.Actuators.Valves.TwoWayPressureIndependent\">
IBPSA.Fluid.Actuators.Valves.TwoWayPressureIndependent</a>, except for adaptations for damper parameters.
Please see that documentation for more information.
</p>
<h4>Computation of the fractional opening</h4>
<p>
The fractional opening of the damper is computed by
</p>
<ul>
<li>
inverting the quadratic flow function to compute the flow coefficient
from the flow rate and the pressure drop values;
</li>
<li>
inverting the exponential characteristics to compute the fractional opening
from the loss coefficient value (directly derived from the flow coefficient).
</li>
</ul>
<p>
Below a threshold value of the input control signal (fixed at 0.02) the fractional opening
is forced to zero and no more related to the actual flow coefficient of the damper.
This avoids steep transient of the computed opening while transitioning from reverse flow.
This is to be considered as a modeling workaround to prevent control chattering during
shut off operation (while avoiding an additional state variable).
</p>
</html>",
revisions="<html>
<ul>
<li>
December 23, 2019 by Antoine Gautier:<br/>
Refactored as the model can now extend directly
<a href=\"modelica://IBPSA.Fluid.Actuators.BaseClasses.PartialDamperExponential\">
IBPSA.Fluid.Actuators.BaseClasses.PartialDamperExponential</a>.<br/>
This is for
<a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/1188\">#1188</a>.
</li>
<li>
March 21, 2017 by David Blum:<br/>
First implementation.
</li>
</ul>
</html>"),
   Icon(graphics={Line(
         points={{0,100},{0,-24}}),
        Rectangle(
          extent={{-100,40},{100,-42}},
          lineColor={0,0,0},
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={192,192,192}),
        Rectangle(
          extent={{-100,22},{100,-24}},
          lineColor={0,0,0},
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={0,127,255})}));
end PressureIndependent;
