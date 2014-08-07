        


        muscles.(MuscNames{ii}).coordinates.(coordNames{k}).coordValue      = coordValueArray ; 
        muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberlength     = fiberlength ; 
        muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberlengthNorm = fiberlengthNorm ; 
        muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberVelocity   = fiberVelocity ; 
        muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberForce      = fiberForce ; 
        
        
        
        X =  muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberlengthNorm;
        Y =  muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberNormVelocity;
        Z =  muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberForce;
        
        
  
        [nLen nVel] = size(X)
        
        
        
        hold on 
        for i = 1 : nLen
            
            for u = 1 : nVel
                
                
                scatter3(X(i,u),Y(i,u),Z(i,u))
            
            
            
            end
            
        end
            
        scatter3(X,Y,Z)
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        