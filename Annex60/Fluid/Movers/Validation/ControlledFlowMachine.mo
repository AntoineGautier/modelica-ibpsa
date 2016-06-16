within Annex60.Fluid.Movers.Validation;
model ControlledFlowMachine "Fans with different control signals as input"
  extends Modelica.Icons.Example;
  extends Annex60.Fluid.Movers.Validation.BaseClasses.ControlledFlowMachine(
    fan4(addPowerToMedium=false, filteredSpeed=false,
      redeclare Annex60.Fluid.Movers.Data.Pumps.Wilo.Stratos32slash1to12 per,
      energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial),
    fan1(addPowerToMedium=false,
      redeclare Annex60.Fluid.Movers.Data.Pumps.Wilo.Stratos32slash1to12 per,
      filteredSpeed=true,
      energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial),
    fan2(addPowerToMedium=false, filteredSpeed=false,
      redeclare Annex60.Fluid.Movers.Data.Pumps.Wilo.Stratos32slash1to12 per,
      energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial),
    fan3(addPowerToMedium=false, filteredSpeed=false,
      redeclare Annex60.Fluid.Movers.Data.Pumps.Wilo.Stratos32slash1to12 per,
      energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial),
    gain(k=3580));

  annotation (
experiment(StopTime=600),
__Dymola_Commands(file="modelica://Annex60/Resources/Scripts/Dymola/Fluid/Movers/Validation/ControlledFlowMachine.mos"
        "Simulate and plot"),
    Documentation(info="<html>
This example demonstrates the use of the flow model with four different configurations.
At steady-state, all flow models have the same mass flow rate and pressure difference.
Note that <code>addPowerToMedium=false</code> since otherwise,
Dymola computes the enthalpy change of the component as a fraction <code>(k*m_flow+P_internal)/m_flow</code>
which leads to an error because of <code>0/0</code> at zero flow rate.
</html>", revisions="<html>
</html>"),
    Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-160,-100},{160,
            160}})));
end ControlledFlowMachine;
