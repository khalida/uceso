classdef Battery < handle
    %BATTERY Represent a battery, track SoC, check for violations etc.

    properties
        SoC
        capacity
        maxChargeRate
        maxChargeEnergy
    end
    
    methods
        % Constructor
        function obj = Battery(cfg, capacity)
            if nargin > 0
                obj.capacity = capacity;
                obj.SoC = 0.5*capacity;
                obj.maxChargeRate = cfg.sim.batteryChargingFactor*...
                    capacity;
                
                obj.maxChargeEnergy = obj.maxChargeRate/...
                    cfg.sim.stepsPerHour;
            end
        end
        
        % Attempt to put kWh into battery
        function chargeBy(this, kWhCharge)
            
            % Check for charge rate constraint violation:
            if kWhCharge > this.maxChargeEnergy
                error(['Charge constraint violated, kWhCharge:'...
                    num2str(kWhCharge) ', maxChargeEnergy:'...
                    num2str(this.maxChargeEnergy)]);
            end
            
            % Check for discharge rate constraint violation:
            if kWhCharge < -this.maxChargeEnergy
                error(['Discharge constraint violated, kWhCharge:'...
                    num2str(kWhCharge) ', -maxChargeEnergy:'...
                    num2str(-this.maxChargeEnergy)]);
            end
            
            % Check for upper SoC violation
            if kWhCharge + this.SoC > this.capacity
                error(['Upper SoC constraint violation, SoC+kWhCharge:'...
                    num2str(kWhCharge + this.SoC) ', capacity:'...
                    num2str(this.capacity)]);
            end
            
            % Check for lower SoC violation
            if kWhCharge + this.SoC < 0
                error(['Lower SoC constraint violation, SoC+kWhCharge:'...
                    num2str(kWhCharge + this.SoC)]);
            end
            
            % All constraints OK, so update charge in battery
            this.SoC = this.SoC + kWhCharge;
        end
        
        % Constraint kWh charge decision to batteries capability
        function ltdCharge = limitCharge(this, kWhCharge)
            
            % Initially set value to requested charge value
            ltdCharge = kWhCharge;
            
            % Check for charge rate constraint violation:
            if kWhCharge > this.maxChargeEnergy
                ltdCharge = this.maxChargeEnergy;
            end
            
            % Check for discharge rate constraint violation:
            if kWhCharge < -this.maxChargeEnergy
                ltdCharge = -this.maxChargeEnergy;
            end
            
            % Check for upper SoC violation
            if kWhCharge + this.SoC > this.capacity
                ltdCharge = this.capacity - this.SoC;
            end
            
            % Check for lower SoC violation
            if kWhCharge + this.SoC < 0
                ltdCharge = -this.SoC;
            end
        end

        % Reset the SoC of battery to starting value (0.5xcapacity)
        function reset(this)
            this.SoC = 0.5*this.capacity;
        end
    end
end
