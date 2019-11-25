classdef virtualMarkerManager < matlab.mixin.SetGet
%% virtualMarkerManager(model, trcManager)
%   Class that manages the computation and addition of virtual markers to a
%   trc data structure. This includes Hip joint, Helical Axis, and joint
%   mid-point calculations. 
    properties (Access = private)
        
        
        
    end
    methods
        function self = virutalMarkerManager()
            
        end
    end
    methods (Static)
        function [Cr] = CoR_Estimation(TrP)
            %-------------------------------------------------------------------------
            %[CR] = COR_ESTIMATION(TrP)
            %   COR_ESTIMATION: Calculation of the relative center of rotation (CoR)
            %   between body A (proximal)and body B (distal) in the coordinate system
            %   (CS) of the body A.
            %
            %   INPUT: TrP - matrix containing the trajectories of the markers attached
            %   to the body B and expressed in the CS of  body A. dim(TrP)= N x 3p
            %   where N is number of samples and p is the number of distal markers
            %
            %   OUTPUT: Cr - rotation center coordinates in the CS of A (Cx,Cy,Cz)
            %
            %   COMMENTS: COR_ESTIMATION provides the Centre of the bias-compensated quartic
            %   best fitted sphere (S4). The CR is determined through a closed form 
            %   minimization of the quartic objective function (Gamage and Lasenby, 2002). 
            %   The bias is compensated for by solving it iteratively using, at each iteration, 
            %   the previous solution as initial estimate and introducing a correction term,
            %   which incorporates the latter estimate and a model of the photogrammetric
            %   error, detailed in Halvorsen (2003). The S4 algorithm has been proved to
            %   the best among the best performing algorithms both in simulation
            %   (Camomilla et al., 2006) and in in vitro
            %   (Cereatti et al., 2009). For optimal results the number of samples should
            %   higher than 500 (Camomilla et al., 2006).   
            %
            % References: 
            % 1) Gamage, S.S.H.U., Lasenby, J., 2002. New least squares solutions for
            % estimating the average centre of rotation and the axis of rotation.
            % Journal of Biomechanics 35, 87?93.
            % 2) Halvorsen, K., 2003. Bias compensated least square estimate of the
            % center of rotation. Journal of Biomechanics 36, 999?1008.
            % 3) Camomilla, V., Cereatti, A., Vannozzi, G., Cappozzo, A., 2006. An
            % optimized protocol for hip joint centre determination using the
            % functional method. Journal of Biomechanics 39, 1096?1106.
            % 4) Cereatti, A., Donati, M., Camomilla, V., Margheritini, F., Cappozzo,
            % A., 2009. Hip joint centre location: an ex vivo study. Journal of
            % Biomechanics 42, 818?823.
            % -------------------------------------------------------------------------
            % $ Version: 1.0 $
            % CODE by Andrea Cereatti, 2014. 
            % -------------------------------------------------------------------------
            [r c] = size(TrP);
            if r<500
                warning('The number of samples for the identification of the CoR could be too small, for a more accurate estimate please collect a larger number of samples');
            end
            D = zeros(3);
            V1 = [];
            V2 = [];
            V3 = [];
            b1 = [0 0 0];
            Cr = [];
            Cm_in = [];
            % Computation of the terms of eq.5 of Gamage and Lasenby (2002)
            for j = 1:3:c
                d1 = zeros(3);
                V2a = 0;
                V3a = [0 0 0];
                for i = 1:r 
                    d1 = [d1+TrP(i,j:j+2)'*(TrP(i,j:j+2))]; %dim(3x3)
                    a = (TrP(i,j).^2+TrP(i,j+1).^2+TrP(i,j+2).^2); %dim(1)
                    V2a = V2a+a; % dim(1)
                    V3a = V3a+a*TrP(i,j:j+2); %dim(1x3)
                end
                D = D+(d1/r); %dim(3x3)
                V2 = [V2,V2a/r]; %dim(1xp)    
                b1 = [b1+V3a/r]; %dim(1x3)
            end

            V1 = mean(TrP); %dim(1x3p)
            p = size(V1,2);
            e1 = 0;
            E = zeros(3);
            f1 = [0 0 0];
            F = [0 0 0];
            for k = 1:3:p
                 e1 = V1(k:k+2)'*V1(k:k+2); %dim(3x3)
                 E = E+e1; %dim(3x3)
                 f1 = V2((k-1)/3+1)*V1(k:k+2); %dim(1x3)
                 F = F+f1; %dim(1x3)
            end
            % Coefficients of the linear system reported in eq.5 of Gamage and Lasenby (2002)
            A = 2*(D-E); %dim(3x3)
            B =(b1-F)';  %dim(3x1)
            [U,S,V] = svd(A); %the linear system is solved using the singular value decomposition
            Cr_in = V*inv(S)*U'*B; %dim(1x3)CoR estimate without Halvorsen's bias correction
            Cr_p = Cr_in+[1,1,1]'; %To enter in the while cycle
            kk = 0;
            % Bias compensated least square estimate proposed by Halvorsen (2003)
            while spatialMath.distanceBetweenPoints(Cr_p',Cr_in') > 0.0000001
                Cr_p = Cr_in; %initial estimate
                sigma2 = []; %noise variance

                %Computation of the noise variance sigma2
                for j=1:3:c
                    marker = TrP(:,j:j+2);
                    Ukp = marker-(Cr_in*ones(1,r))';
                    %Computation of u^2
                    u2 = 0;
                    app = [];
                    for i = 1:r
                        u2 = u2+Ukp(i,:)*Ukp(i,:)';
                        app = [app,Ukp(i,:)*Ukp(i,:)'];
                    end
                    u2 = u2/r;
                    % computation of sigma
                    sigmaP = 0;
                    for i = 1:r
                        sigmaP = sigmaP+(app(i)-u2)^2;
                    end
                    sigmaP = sigmaP/(4*u2*r);
                    sigma2 =[sigma2;sigmaP];
                end
                sigma2 = mean(sigma2);

                %Computation of the correction term Bcorr
                deltaB = 0;
                for j = 1:3:c
                    deltaB = deltaB+V1(j:j+2)'-Cr_in;
                end
                deltaB = 2*sigma2*deltaB;
                Bcorr = B-deltaB; % corrected term B

                %Iterative estimation of the CoR according to Halvorsen(2003)
                [U,S,V] = svd(A);
                Cr_in = V*inv(S)*U'*Bcorr;
            end
            Cr = Cr_in;
        end
    end
end
    

