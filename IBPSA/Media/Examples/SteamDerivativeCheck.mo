within IBPSA.Media.Examples;
model SteamDerivativeCheck "Model that tests the derivative implementation"
  extends Modelica.Icons.Example;

   package Medium = IBPSA.Media.Steam;

    Modelica.SIunits.Temperature T "Temperature";
    Modelica.SIunits.SpecificEnthalpy hVapSym "Vapor phase specific enthalpy";
    Modelica.SIunits.SpecificEnthalpy hVapCod "Vapor phase specific enthalpy";
    Modelica.SIunits.SpecificHeatCapacity cpSym "Specific heat capacity";
    Modelica.SIunits.SpecificHeatCapacity cpCod "Specific heat capacity";
    Modelica.SIunits.SpecificHeatCapacity cvSym "Specific heat capacity";
    Modelica.SIunits.SpecificHeatCapacity cvCod "Specific heat capacity";
    constant Real convT(unit="K/s3") = 270
    "Conversion factor to satisfy unit check";
initial equation
     hVapSym = hVapCod;
     cpSym   = cpCod;
     cvSym   = cvCod;
equation
    T = 273.15+110+convT*time^3;
    hVapCod=Medium.specificEnthalpy(
      Medium.setState_pTX(
         p=1e5,
         T=T,
         X=Medium.X_default));
    assert(abs(hVapCod-hVapSym) < 1E-2, "Model has an error");
    der(hVapCod)=der(hVapSym);

    cpCod=Medium.specificHeatCapacityCp(
      Medium.setState_pTX(
         p=1e5,
         T=T,
         X=Medium.X_default));
    der(cpCod)=der(cpSym);
    assert(abs(cpCod-cpSym) < 1E-2, "Model has an error");

     cvCod=Medium.specificHeatCapacityCv(
      Medium.setState_pTX(
         p=1e5,
         T=T,
         X=Medium.X_default));
    der(cvCod)=der(cvSym);
    assert(abs(cvCod-cvSym) < 1E-2, "Model has an error");

   annotation(experiment(
                 StartTime=0, StopTime=1,
                 Tolerance=1E-8),
__Dymola_Commands(file="modelica://IBPSA/Resources/Scripts/Dymola/Media/Examples/SteamDerivativeCheck.mos"
        "Simulate and plot"),
      Documentation(info="<html>
<p>
This example checks whether the function derivative
is implemented correctly. If the derivative implementation
is not correct, the model will stop with an assert statement.
</p>
</html>",   revisions="<html>
<ul>
<li>
March 6, 2020, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>"));
end SteamDerivativeCheck;
