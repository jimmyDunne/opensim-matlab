




hold on


h1 = plot(Jt_sync101(:,4),'r')
h2 = plot(grf_sync101(:,2)/10,'b')
title('knee moment from Inv Dyn')
xlabel('stride % normalised to 50 points')
ylabel('Nm') 
legend([h1 h2],{'Knee' 'Vert Grf (scaled down)'}, 'location','northeast')





hold on
h1 = plot(torqueProfile.hip_adduction_r.reserves(:,1),'b');
plot(torqueProfile.hip_adduction_r.reserves(:,2:end),'b')

h2 = plot(torqueProfile.hip_rotation_r.reserves(:,1),'k');
plot(torqueProfile.hip_rotation_r.reserves(:,2:end),'k')

h3 = plot(torqueProfile.hip_flexion_r.reserves(:,1),'g');
plot(torqueProfile.hip_flexion_r.reserves(:,2:end),'g')

h4 = plot(torqueProfile.knee_angle_r.reserves(:,1),'r');
plot(torqueProfile.knee_angle_r.reserves(:,2:end),'r');

h5 = plot(torqueProfile.ankle_angle_r.reserves(:,1),'c');
plot(torqueProfile.ankle_angle_r.reserves(:,2:end),'c')

title('Reserve Actuators when reducing Hip Adductor Strength (loaded) ')
xlabel('stride % normalised to 50 points')
ylabel('Nm') 
legend([h1 h2 h3 h4 h5],{'Hip Add','Hip Rot','Hip Flex','Knee Flex'...
                        ,'Ank ang'}, 'location','southeast')


                    
hold on
                    
  h1 =   plot( torqueProfile.hip_adduction_r.reservePercentage(:,1) *100 , 'b' )
        plot( torqueProfile.hip_adduction_r.reservePercentage(:,2:end) *100 , 'b' )
        
title('Hip Add reserve as % of coordinate torque (loaded) ')
xlabel('stride % normalised to 50 points')
ylabel('% of coordinate torque') 
legend([h1],{'Hip Add'}, 'location','northwest')
    
        
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    