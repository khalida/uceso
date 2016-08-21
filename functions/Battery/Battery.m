classdef Battery < handle
    %BATTERY Represent a battery, track SoC, check for violations etc.
    
    properties
        cfg                 % local copy of config variable
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
        eps                 % threshold for constraint checking
        cumulativeDamage    % cumulative fractional damage in Sim so far
        cumulativeValue     % total value of batt. in Sim so far
    end
    
    methods
        % Constructor
        function obj = Battery(cfg, capacity)
            if nargin > 0
                obj.cfg = cfg;
                obj.capacity = capacity;
                obj.maxChargeRate = cfg.sim.batteryChargingFactor*...
                    capacity;
                obj.eps = cfg.sim.eps;
                
                if isequal(obj.cfg.type, 'oso')
                    % Initialize battery for Oso problem
                    if cfg.opt.statesTotal == 0
                        obj.statesInt = (0:(floor(capacity*...
                            cfg.opt.statesPerKwh))) + 1;
                        
                        obj.increment = 1/cfg.opt.statesPerKwh;
                    else
                        obj.statesInt = (0:cfg.opt.statesTotal) + 1;
                        obj.increment = capacity/cfg.opt.statesTotal;
                    end
                    obj.state = floor((0.5*capacity)/obj.increment)+1;
                    obj.SoC = (obj.state-1)*obj.increment;
                    obj.statesKwh = (obj.statesInt-1).*obj.increment;
                    obj.maxDischargeStep = floor((obj.maxChargeRate/...
                        cfg.sim.stepsPerHour)/obj.increment);
                    obj.minDischargeStep = -obj.maxDischargeStep;
                    obj.cumulativeDamage = eps;
                    obj.cumulativeValue = 0;
                    
                else
                    % Initialize battery for minMaxDemand problem
                    obj.maxChargeEnergy = obj.maxChargeRate/...
                        cfg.sim.stepsPerHour;
                    obj.SoC = 0.5*obj.capacity;
                end
            end
        end
        
        % Attempt to put kWh into battery: minMaxDemand opt only
        function chargeBy(this, kWhCharge)
            if isequal(this.cfg.type, 'oso')
                error('Cannot charge by continuous value for oso opt');
            end
            % Check for charge rate constraint violation:
            if kWhCharge > this.maxChargeEnergy + this.eps
                error(['Charge constraint violated, kWhCharge:'...
                    num2str(kWhCharge) ', maxChargeEnergy:'...
                    num2str(this.maxChargeEnergy)]);
            end
            
            % Check for discharge rate constraint violation:
            if kWhCharge < -this.maxChargeEnergy - this.eps
                error(['Discharge constraint violated, kWhCharge:'...
                    num2str(kWhCharge) ', -maxChargeEnergy:'...
                    num2str(-this.maxChargeEnergy)]);
            end
            
            % Check for upper SoC violation
            if kWhCharge + this.SoC > this.capacity + this.eps
                error(['Upper SoC constraint violation, SoC+kWhCharge:'...
                    num2str(kWhCharge + this.SoC) ', capacity:'...
                    num2str(this.capacity)]);
            end
            
            % Check for lower SoC violation
            if kWhCharge + this.SoC < -this.eps
                error(['Lower SoC constraint violation, SoC+kWhCharge:'...
                    num2str(kWhCharge + this.SoC)]);
            end
            
            % All constraints OK, so update charge in battery
            this.SoC = this.SoC + kWhCharge;
        end
        
        % Attempt to charge battery by nSteps
        function chargeStep(this, stepCharge, valueOverNB)
            if isequal(this.cfg.type, 'minMaxDemand')
                error('Cannot charge by step for minMaxDemand opt');
            end
            
            % Check for step not being integer
            if ~isWholeNumber(stepCharge)
                error('stepCharge must be an integer');
            end
            
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
            
            % Also update total damage and total value'
            this.cumulativeDamage = this.cumulativeDamage + ...
                calcFracDegradation(this.cfg, this, this.state,...
                -stepCharge);
            
            this.cumulativeValue = this.cumulativeValue + valueOverNB;
            
            %if this.cumulativeDamage > 1.0
            %    warning('battery cumulative damage exceeded 1.0');
            %end
            %
            %if this.cumulativeValue < 0.0
            %    disp('CumulativeValue: ');
            %    disp(this.cumulativeValue);
            %    disp('CumulativeDamage: ');
            %    disp(this.cumulativeDamage);
            %    disp('ValueEst: ');
            %    disp(this.cumulativeValue/this.cumulativeDamage);
            %   warning('WARN: battery cumulative value negative');
            %end
        end
        
        % Constrain kWh charge decision to batteries capability
        function ltdCharge = limitCharge(this, kWhCharge)
            if isequal(this.cfg.type, 'oso')
                error('Cannot charge limit continuous value for oso opt');
            end
            
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
            if isequal(this.cfg.type, 'minMaxDemand')
                error('Cannot limit charge step for minMaxDemand opt');
            end
            
            % Check for step not being integer
            if ~isWholeNumber(chargeStep)
                error('stepCharge must be an integer');
            end
            
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
        function reset(this)
            if isequal(this.cfg.type, 'oso')
                this.state = floor((0.5*this.capacity)/this.increment) + 1;
                this.SoC = (this.state-1)*this.increment;
                this.cumulativeDamage = this.eps;
                this.cumulativeValue = 0;
            else
                this.SoC = 0.5*this.capacity;
            end
        end
        
        % Set SoC of battery to a specific value [kWh]
        function resetTo(this, value)
            if isequal(this.cfg.type, 'oso')
                this.state = floor(value/this.increment) + 1;
                this.SoC = (this.state-1)*this.increment;
                this.cumulativeDamage = this.eps;
                this.cumulativeValue = 0;
            else
                this.SoC = value;
            end
        end
        
        function randomReset(this)
            if isequal(this.cfg.type, 'oso')
                this.state = randsample(this.statesInt, 1);
                this.SoC = (this.state-1)*this.increment;
            else
                this.SoC = rand(1,1).*(this.capacity - 0) + 0;
            end
        end
        
        % Return current estimate of the value of the battery
        function value = Value(this)
            if isequal(this.cfg.type, 'minMaxDemand')
                error('Cannot return value for minMaxDemand opt');
            else
                if this.cfg.sim.updateBattValue
                    value = this.cumulativeValue/this.cumulativeDamage;
                else
                    value = this.cfg.bat.costPerKwhUsed;
                end
            end
        end
        
        % Return STRUCT copy of current battery object
        function battStruct = getStruct(this)
            batteryFields = fieldnames(this);
            for fieldIdx = 1:length(batteryFields)
                thisField = batteryFields{fieldIdx};
                battStruct.(thisField) = this.(thisField);
            end
        end
    end
end
