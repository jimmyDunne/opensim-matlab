        


        muscles.(MuscNames{ii}).coordinates.(coordNames{k}).coordValue      = coordValueArray ; 
        muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberlength     = fiberlength ; 
        muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberlengthNorm = fiberlengthNorm ; 
        muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberVelocity   = fiberVelocity ; 
        muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberForce      = fiberForce ; 
        
        
        
        % X =  muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberlengthNorm;
        X =  muscles.(MuscNames{ii}).coordinates.(coordNames{k}).coordValuePlot;
        
        % Y =  muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberVelocityNorm;
        Y =  muscles.(MuscNames{ii}).coordinates.(coordNames{k}).coordSpeedArray;
        
        Z =  muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberForce;
        
        
  
        [nLen nVel] = size(X)
        
        
        
        hold on 
        for i = 1 : 5 :nLen
            
            for u = 1 : 5 :nVel
                
                
                scatter3(X(i,u),Y(i,u),Z(i,u))
            
            
            
            end
            
        end
            
        
        
        %% 
        
        % X =  muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberlengthNorm;
        X =  muscles.(MuscNames{ii}).coordinates.(coordNames{k}).coordValuePlot;
        Y =  muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberVelocityNorm;
        Z =  muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberForce;
        
        
        for i = 1 : 5 :nLen
            
            for u = 1 : 5 :nVel
                
                
                plot( X(:,u),Z(:,u) )
            
            
                plot( Y(133,:),Z(133,:) )
                
                
                
            end
            
        end
       
        
        
        
        
        
        
        
        
        
        
        
        
        