within IBPSA.Fluid.Actuators.Dampers;
model Exponential
  "Damper model with exponential characteristics and optional fixed flow resistance"
  extends IBPSA.Fluid.Actuators.BaseClasses.PartialDamperExponential;

annotation (
defaultComponentName="dam",
Documentation(info="<html>
<h4>General description</h4>
<p>
Model of two resistances in series. One (optional) resistance has a fixed flow coefficient.
The other resistance corresponds to a damper whose loss coefficient is an exponential function
of the opening angle.
</p>
<p>
If <code>dp_nominalIncludesDamper=true</code>, then the parameter <code>dpExp_nominal</code>
is equal to the pressure drop of the damper plus the fixed flow resistance at the nominal
flow rate.
If <code>dp_nominalIncludesDamper=false</code>, then <code>dpExp_nominal</code>
does not include the flow resistance of the air damper.
</p>
<p>
If <code>char_linear=true</code>, then the lumped flow coefficient
(for both damper and optional fixed flow resistance) varies linearly with the filtered control
input signal <code>y_actual</code>.
This yields a linear relationship between the mass flow rate and <code>y_actual</code> when
the model is exposed to constant pressure boundary conditions. This option is used to approximate
a feedback control compensating for the static nonlinearities of the controlled system.
</p>
<h4>Exponential damper model description</h4>
<p>
The relationship between the damper loss coefficient and the opening angle is modeled with
an exponential function. The model is as in ASHRAE 825-RP.
A control signal of <code>y=0</code> means the damper is closed, and <code>y=1</code> means the damper
is open. This is opposite of the implementation of ASHRAE 825-RP, but used here
for consistency within this library.
</p>
<p>
For <code>yL &lt; y &lt; yU</code>, the damper characteristics is
</p>
<p align=\"center\" style=\"font-style:italic;\">
  k<sub>d</sub>(y) = exp(a+b (1-y)).
</p>
<p>
Outside this range, the damper characteristics is defined by a quadratic polynomial that
matches the damper resistance at <code>y=0</code> and <code>y=yL</code> or <code>y=yU</code> and
<code>y=1</code>, respectively. In addition, the polynomials are such that
<i>k<sub>d</sub>(y)</i> is
differentiable in <i>y</i> and the derivative is continuous.
</p>
<p>
The damper characteristics <i>k<sub>d</sub>(y)</i> is then used to
compute the flow coefficient <i>k(y)</i> as
</p>
<p align=\"center\" style=\"font-style:italic;\">
k(y) = (2 &rho; &frasl; k<sub>d</sub>(y))<sup>1/2</sup> A,
</p>
<p>
where <i>A</i> is the face area, which is computed using the nominal
mass flow rate <code>m_flow_nominal</code>, the nominal velocity
<code>v_nominal</code> and the density of the medium. The flow coefficient <i>k(y)</i>
is used to compute the mass flow rate versus pressure
drop relation as
</p>
<p align=\"center\" style=\"font-style:italic;\">
  m&#775; = sign(&Delta;p) k(y)  &radic;<span style=\"text-decoration:overline;\">&nbsp;&Delta;p &nbsp;</span>
</p>
<p>
with regularization near the origin.
</p>
<p>
ASHRAE 825-RP lists the following parameter values as typical:
<br />
</p>
<table summary=\"summary\" border=\"1\" cellspacing=\"0\" cellpadding=\"2\" style=\"border-collapse:collapse;\">
<tr>
<td></td><th>opposed blades</th><th>single blades</th>
</tr>
<tr>
<td>yL</td><td>15/90</td><td>15/90</td>
</tr>
<tr>
<td>yU</td><td>55/90</td><td>65/90</td>
</tr>
<tr>
<td>k0</td><td>1E6</td><td>1E6</td>
</tr>
<tr>
<td>k1</td><td>0.2 to 0.5</td><td>0.2 to 0.5</td>
</tr>
<tr>
<td>a</td><td>-1.51</td><td>-1.51</td>
</tr>
<tr>
<td>b</td><td>0.105*90</td><td>0.0842*90</td>
</tr>
</table>
<p>
<br />
ASHRAE 2009 <i>Dampers and Airflow Control</i> provides additional data.
<br />
</p>
<h4>References</h4>
<p>
P. Haves, L. K. Norford, M. DeSimone and L. Mei,
<i>A Standard Simulation Testbed for the Evaluation of Control Algorithms &amp; Strategies</i>,
ASHRAE Final Report 825-RP, Atlanta, GA.
</p>
<p>
L. G. Felker and T. L. Felker,
<i>Dampers and Airflow Control</i>,
ASHRAE, Atlanta, GA, 2009.
</p>
</html>", revisions="<html>
<ul>
<li>
April 19, 2019, by Antoine Gautier:<br/>
Refactored <code>Exponential</code> and <code>VAVBoxExponential</code> into one single class.<br/>
Added the option for characteristics linearization.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/1298\">#1298</a>.
</li>
<li>
March 22, 2017, by Michael Wetter:<br/>
Updated documentation.
</li>
<li>
January 22, 2016, by Michael Wetter:<br/>
Corrected type declaration of pressure difference.
This is
for <a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/404\">#404</a>.
</li>
<li>
April 14, 2014 by Michael Wetter:<br/>
Improved documentation.
</li>
<li>
September 26, 2013 by Michael Wetter:<br/>
Moved assignment of <code>kDam_default</code> and <code>kThetaSqRt_default</code>
from <code>initial algorithm</code> to the variable declaration, to avoid a division
by zero in OpenModelica.
</li>
<li>
December 14, 2012 by Michael Wetter:<br/>
Renamed protected parameters for consistency with the naming conventions.
</li>
<li>
April 13, 2010 by Michael Wetter:<br/>
Added <code>noEvent</code> to guard evaluation of the square root
for negative numbers during the solver iterations.
</li>
<li>
February 24, 2010 by Michael Wetter:<br/>
Added parameter <code>dp_nominalIncludesDamper</code>.
</li>
<li>
June 22, 2008 by Michael Wetter:<br/>
Extended range of control signal from 0 to 1 by implementing the function
<a href=\"modelica://IBPSA.Fluid.Actuators.BaseClasses.exponentialDamper\">
IBPSA.Fluid.Actuators.BaseClasses.exponentialDamper</a>.
</li>
<li>
June 10, 2008 by Michael Wetter:<br/>
Introduced new partial base class,
<a href=\"modelica://IBPSA.Fluid.Actuators.BaseClasses.PartialDamperExponential\">
PartialDamperExponential</a>.
</li>
<li>
September 11, 2007 by Michael Wetter:<br/>
Redefined <code>kRes</code>, now the pressure drop of the fully open damper is subtracted from the fixed resistance.
</li>
<li>
June 30, 2007 by Michael Wetter:<br/>
Introduced new partial base class,
<a href=\"modelica://IBPSA.Fluid.Actuators.BaseClasses.PartialActuator\">PartialActuator</a>.
</li>

<li>
July 27, 2007 by Michael Wetter:<br/>
Introduced partial base class.
</li>
<li>
July 20, 2007 by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"), Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
            {100,100}}), graphics={
        Text(
          extent={{-110,-34},{12,-100}},
          lineColor={0,0,255},
          textString="dpExp_nominal=%dp_nominal"),
        Text(
          extent={{-102,-76},{10,-122}},
          lineColor={0,0,255},
          textString="m0=%m_flow_nominal"),
        Polygon(
          points={{-24,-16},{24,22},{24,14},{-24,-24},{-24,-16}},
          lineColor={0,0,0},
          fillPattern=FillPattern.Solid)}));
end Exponential;
