classdef Battery
    %BATTERY Represent a battery, track SoC, check for violations etc.

    properties
        SoC
        capacity
        maxChargeRate
        maxChargeEnergy
    end
    
    methods
        % Constructor
        function battery = Battery(cfg, capacity)
            if nargin > 0
                battery.capacity = capacity;
                battery.SoC = 0.5*capacity;
                battery.maxChargeRate = cfg.sim.batteryChargingFactor*...
                    capacity;
                
                battery.maxChargeEnergy = battery.maxChargeRate/...
                    cfg.sim.stepsPerHour;
            end
        end
        
        % Attempt to put kWh into battery
        function battery = chargeBy(battery, kWhCharge)
            
            % Check for charge rate constraint violation:
            if kWhCharge > battery.maxChargeEnergy
                error(['Charge constraint violated, kWhCharge:'...
                    num2str(kWhCharge) ', maxChargeEnergy:'...
                    num2str(battery.maxChargeEnergy)]);
            end
            
            % Check for discharge rate constraint violation:
            if kWhCharge < -battery.maxChargeEnergy
                error(['Discharge constraint violated, kWhCharge:'...
                    num2str(kWhCharge) ', -maxChargeEnergy:'...
                    num2str(-battery.maxChargeEnergy)]);
            end
            
            % Check for upper SoC violation
            if kWhCharge + battery.SoC > battery.capacity
                error(['Upper SoC constraint violation, SoC+kWhCharge:'...
                    num2str(kWhCharge+battery.SoC) ', capacity:'...
                    num2str(battery.capacity)]);
            end
            
            % Check for lower SoC violation
            if kWhCharge + battery.SoC < 0
                error(['Lower SoC constraint violation, SoC+kWhCharge:'...
                    num2str(kWhCharge+battery.SoC)]);
            end
            
            % All constraints OK, so update charge in battery
            battery.SoC = battery.SoC + kWhCharge;
        end
        
        % Constraint kWh charge decision to batteries capability
        function ltdCharge = limitCharge(battery, kWhCharge)
            
            % Initially set value to requested charge value
            ltdCharge = kWhCharge;
            
            % Check for charge rate constraint violation:
            if kWhCharge > battery.maxChargeEnergy
                ltdCharge = battery.maxChargeEnergy;
            end
            
            % Check for discharge rate constraint violation:
            if kWhCharge < -battery.maxChargeEnergy
                ltdCharge = -battery.maxChargeEnergy;
            end
            
            % Check for upper SoC violation
            if kWhCharge + battery.SoC > battery.capacity
                ltdCharge = battery.capacity - battery.SoC;
            end
            
            % Check for lower SoC violation
            if kWhCharge + battery.SoC < 0
                ltdCharge = -battery.SoC;
            end
        end

        % Reset the SoC of battery to starting value (0.5xcapacity)
        function battery = reset(battery)
            battery.SoC = 0.5*battery.capacity;
        end
    end
end
