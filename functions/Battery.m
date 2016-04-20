classdef Battery < handle
    %BATTERY Represent a battery, track SoC, check for violations etc.
    
    properties
        type                % store solution type {oso, minMaxDemand}
        SoC                 % kWh state of charge (energy in battery)
        state               % int state of charge
        capacity            % kWh capacity
        maxChargeRate       % max kW in/out of battery
        maxChargeEnergy     % max kWh/interval in/out of battery
        increment           % oso only; kWh between charge levels
        statesInt           % list of integer charge levels
        statesKwh           % list of kWh charge levels
        maxDischargeStep    % maxm No. of steps batt. can be discharged
        minDischargeStep    % minm (most -ve) steps batt can be discharged
    end
    
    methods
        % Constructor
        function obj = Battery(cfg, capacity)
            if nargin > 0
                obj.type = cfg.type;
                obj.capacity = capacity;
                obj.maxChargeRate = cfg.sim.batteryChargingFactor*...
                    capacity;
                
                if isequal(cfg.type, 'oso')
                    % Initialize battery for Oso problem
                    obj.statesInt = (0:(cfg.sim.batteryCapacity*...
                        cfg.opt.statesPerKwh)) + 1;
                    
                    obj.increment = 1/cfg.opt.statesPerKwh;
                    obj.state = floor((0.5*capacity)/obj.increment)+1;
                    obj.SoC = (obj.state-1)*obj.increment;
                    obj.statesKwh = (obj.statesInt-1).*obj.increment;
                    obj.maxDischargeStep = floor((obj.maxChargeRate/...
                        cfg.sim.stepsPerHour)/obj.increment);
                    obj.minDischargeStep = -obj.maxDischargeStep;
                else
                    % Initialize battery for minMaxDemand problem
                    obj.maxChargeEnergy = obj.maxChargeRate/...
                        cfg.sim.stepsPerHour;
                end
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
        
        % Attempt to charge battery by nSteps
        function chargeStep(this, stepCharge)
            
            % Check for charge rate constraint violation:
            if stepCharge > -this.minDischargeStep
                error(['Charge constraint violated, stepCharge:'...
                    num2str(stepCharge) ', -minDischargeStep:'...
                    num2str(-this.minDischargeStep)]);
            end
            
            % Check for discharge rate constraint violation:
            if stepCharge < -this.maxDischargeStep
                error(['Discharge constraint violated, stepCharge:'...
                    num2str(stepCharge) ', -maxDischargeStep:'...
                    num2str(-this.maxDischargeStep)]);
            end
            
            % Check for upper SoC violation
            if stepCharge + this.state > max(this.statesInt)
                error(['Upper SoC constraint violation, '...
                    'stepCharge+this.state:' num2str(stepCharge + ...
                    this.state) ', max(this.statesInt):' ...
                    num2str(max(this.statesInt))]);
            end
            
            % Check for lower SoC violation
            if stepCharge + this.state < min(this.statesInt)
                error(['Lower SoC constraint violation, '...
                    'stepCharge+this.state:' ...
                    num2str(stepCharge + this.state)]);
            end
            
            % All constraints OK, so update charge in battery
            this.state = this.state + stepCharge;
            this.SoC = (this.state-1)*this.increment;
        end

        % Constrain kWh charge decision to batteries capability
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
        
        function ltdStep = limitChargeStep(this, chargeStep)
            % Initially set value to requested charge value
            ltdStep = chargeStep;
            
            % Check for charge rate constraint violation:
            if ltdStep > -this.minDischargeStep
                ltdStep = -this.minDischargeStep;
            end
            
            % Check for discharge rate constraint violation:
            if ltdStep < -this.maxDischargeStep
                ltdStep = -this.maxChargeEnergy;
            end
            
            % Check for upper SoC violation
            if this.state + chargeStep > max(this.statesInt)
                ltdStep = max(this.statesInt) - this.state;
            end
            
            % Check for lower SoC violation
            if this.state + chargeStep < min(this.statesInt)
                ltdStep = min(this.statesInt) - this.state;
            end
        end
        
        % Reset the SoC of battery to starting value (0.5xcapacity)
        function reset(this, varargin)
            if isempty(varargin)
                if isequal(this.type, 'oso')
                    this.state = floor((0.5*this.capacity)/this.increment) + 1;
                    this.SoC = (this.state-1)*this.increment;
                else
                    this.SoC = 0.5*this.capacity;
                end
            elseif length(varargin) == 1
                if isequal(this.type, 'oso')
                    this.state = varargin{1};
                    this.SoC = (this.state-1)*this.increment;
                else
                    this.SoC = varargin{1};
                end
            else
                error('too many input arguments');
            end
        end
    end
end
