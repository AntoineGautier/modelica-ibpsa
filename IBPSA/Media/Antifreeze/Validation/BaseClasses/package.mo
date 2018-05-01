within IBPSA.Media.Antifreeze.Validation;
package BaseClasses "Package with base classes for IBPSA.Media.Antifreeze.Validation"
extends Modelica.Icons.BasesPackage;

  partial model FluidProperties
    "Model that tests the implementation of temperature- and concentration-dependent fluid properties"

    replaceable package Medium = Modelica.Media.Interfaces.PartialMedium
      "Medium package";

    parameter Integer n
      "Number of mass fractions to evaluate fluid properties";
    parameter Modelica.SIunits.MassFraction w[n]
      "Mass fraction of additive";
    parameter Modelica.SIunits.Temperature T_min
      "Minimum temperature of mixture";
    parameter Modelica.SIunits.Temperature T_max
      "Maximum temperature of mixture";
    parameter Modelica.SIunits.Temperature reference_T = 293.15
      "Reference temperature";
    Modelica.SIunits.Temperature Tf[n] "Fluid temperature";
    Modelica.SIunits.Density d[n] "Density of fluid mixture";
    Modelica.SIunits.SpecificHeatCapacity cp[n] "Density of fluid mixture";
    Modelica.SIunits.ThermalConductivity lambda[n] "Density of fluid mixture";
    Modelica.SIunits.DynamicViscosity eta[n] "Density of fluid mixture";
    Modelica.SIunits.Temperature T "Temperature";
    Modelica.SIunits.Temperature T_degC "Temperature (in Celsius)";

protected
    parameter Modelica.SIunits.Time dt = 1
      "Simulation length";
    parameter Real convT(unit="K/s") = (T_max-T_min)/dt
      "Rate of temperature change";

  equation
    T = T_min + convT*time;
    T_degC = Modelica.SIunits.Conversions.to_degC(T);
    for i in 1:n loop
      Tf[i] = Modelica.SIunits.Conversions.from_degC(IBPSA.Media.Antifreeze.BaseClasses.polynomialProperty(w[i]*100,reference_T,Medium.propertyCoefficients.wm*100,Medium.propertyCoefficients.Tm,Medium.propertyCoefficients.nw,Medium.propertyCoefficients.nT,Medium.propertyCoefficients.a_Tf));
      d[i] = if T >= Tf[i] then IBPSA.Media.Antifreeze.BaseClasses.polynomialProperty(w[i]*100,T,Medium.propertyCoefficients.wm*100,Medium.propertyCoefficients.Tm,Medium.propertyCoefficients.nw,Medium.propertyCoefficients.nT,Medium.propertyCoefficients.a_d) else 0.;
      cp[i] = if T >= Tf[i] then IBPSA.Media.Antifreeze.BaseClasses.polynomialProperty(w[i]*100,T,Medium.propertyCoefficients.wm*100,Medium.propertyCoefficients.Tm,Medium.propertyCoefficients.nw,Medium.propertyCoefficients.nT,Medium.propertyCoefficients.a_cp) else 0.;
      lambda[i] = if T >= Tf[i] then IBPSA.Media.Antifreeze.BaseClasses.polynomialProperty(w[i]*100,T,Medium.propertyCoefficients.wm*100,Medium.propertyCoefficients.Tm,Medium.propertyCoefficients.nw,Medium.propertyCoefficients.nT,Medium.propertyCoefficients.a_lambda) else 0.;
      eta[i] = if T >= Tf[i] then 1e-3*exp(IBPSA.Media.Antifreeze.BaseClasses.polynomialProperty(w[i]*100,T,Medium.propertyCoefficients.wm*100,Medium.propertyCoefficients.Tm,Medium.propertyCoefficients.nw,Medium.propertyCoefficients.nT,Medium.propertyCoefficients.a_eta)) else 0.;
    end for;

     annotation (
  Documentation(info="<html>
<p>
This example checks the implementation of functions that evaluate the
temperature- and concentration-dependent thermophysical properties of the
medium.
</p>
<p>
Thermophysical properties (density, specific heat capacity, thermal conductivity
and dynamic viscosity) are shown as 0 if the temperature is below the fusion
temperature.
</p>
</html>",
  revisions="<html>
<ul>
<li>
March 14, 2018, by Massimo Cimmino:<br/>
First implementation.
</li>
</ul>
</html>"));
  end FluidProperties;

annotation (preferredView="info", Documentation(info="<html>
<p>
This package contains base classes that are used to construct the models in
<a href=\"modelica://IBPSA.Media.Antifreeze.Validation\">
IBPSA.Media.Antifreeze.Validation</a>.
</p>
</html>"));
end BaseClasses;
