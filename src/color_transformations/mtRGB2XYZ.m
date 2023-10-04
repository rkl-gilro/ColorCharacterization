function [XYZ,xyY]=mtRGB2XYZ(rgb, filename_mat)
% hard coded linear parameters. each col is a channel
% p(1)= intercept, p(2)=slope, p(3) rgb at clipping
% PS=[1.4222    0.5741    1.9211
%    68.9690  170.3329   13.2495
%     0.5016    0.5064    0.5079];


% Intercepts =[    0.6519    1.4222    2.4707 % r=rgb, c=xyz
%     1.6387    0.5741    2.2585
%     1.3853    1.9211   -0.3885];
%
%
% monXYZ=[  66.9860   36.0130    2.5711 % measured
%    28.2980   86.7980   10.0330
%    26.0730    8.6468  138.2000] ;
%
% monXYZ=[66.9985   36.0181    2.5661
%    28.3037   86.8247   10.0261
%    26.0859    8.6511  138.2673]; % predicted


load( filename_mat )


% assume same intercept
% X= rgb(:,1)*(monXYZ(1,1)- PS(1,1))+PS(1,1)  ...
%     + rgb(:,2)*(monXYZ(2,1)- PS(1,2))+PS(1,2)  ...
%      + rgb(:,3)*(monXYZ(3,1)- PS(1,3))+PS(1,3) ;
%
%  Y= rgb(:,1)*(monXYZ(1,2)- PS(1,1))+PS(1,1)  ...
%     + rgb(:,2)*(monXYZ(2,2)- PS(1,2))+PS(1,2)  ...
%      + rgb(:,3)*(monXYZ(3,2)- PS(1,3))+PS(1,3) ;
%
%  Z= rgb(:,1)*(monXYZ(1,3)- PS(1,1))+PS(1,1)  ...
%     + rgb(:,2)*(monXYZ(2,3)- PS(1,2))+PS(1,2)  ...
%      + rgb(:,3)*(monXYZ(3,3)- PS(1,3))+PS(1,3) ;

% different intercepts for XYZ

Xs = nan(size(rgb(:,1),1),3);
Ys = nan(size(rgb(:,1),1),3);
Zs = nan(size(rgb(:,1),1),3);
for ch=1:3
    posx=rgb(:,ch)>PS_XYZ(3,ch,1);
    Xs(posx==0,ch)=rgb(posx==0,ch)*PS_XYZ(2,ch,1)+PS_XYZ(1,ch,1);
    Xs(posx==1,ch)=PS_XYZ(2,ch,1)*PS_XYZ(3,ch,1)+PS_XYZ(1,ch,1);
    
    posy=rgb(:,ch)>PS_XYZ(3,ch,2);
    Ys(posy==0,ch)=rgb(posy==0,ch)*PS_XYZ(2,ch,2)+PS_XYZ(1,ch,2);
    Ys(posy==1,ch)=PS_XYZ(2,ch,2)*PS_XYZ(3,ch,2)+PS_XYZ(1,ch,2);
    
    posz=rgb(:,ch)>PS_XYZ(3,ch,3);
    Zs(posz==0,ch)=rgb(posz==0,ch)*PS_XYZ(2,ch,3)+PS_XYZ(1,ch,3);
    Zs(posz==1,ch)=PS_XYZ(2,ch,3)*PS_XYZ(3,ch,3)+PS_XYZ(1,ch,3);
    
%     Xs(:,ch)=rgb(:,ch)*PS_XYZ(2,ch,1)+PS_XYZ(1,ch,1);
%     Ys(:,ch)=rgb(:,ch)*PS_XYZ(2,ch,2)+PS_XYZ(1,ch,2);
%     Zs(:,ch)=rgb(:,ch)*PS_XYZ(2,ch,3)+PS_XYZ(1,ch,3);
end
%  X= rgb(:,1)  ...
%     + rgb(:,2)*(monXYZ(2,1)- Intercepts(2,1))+Intercepts(2,1)  ...
%      + rgb(:,3)*(monXYZ(3,1)- Intercepts(3,1))+Intercepts(3,1) ;
%
%  Y= rgb(:,1)*(monXYZ(1,2)- Intercepts(1,2))+Intercepts(1,2)  ...
%     + rgb(:,2)*(monXYZ(2,2)- Intercepts(2,2))+Intercepts(2,2)  ...
%      + rgb(:,3)*(monXYZ(3,2)- Intercepts(3,2))+Intercepts(3,2) ;
%
%  Z= rgb(:,1)*(monXYZ(1,3)- Intercepts(1,3))+Intercepts(1,3)  ...
%     + rgb(:,2)*(monXYZ(2,3)- Intercepts(2,3))+Intercepts(2,3)  ...
%      + rgb(:,3)*(monXYZ(3,3)- Intercepts(3,3))+Intercepts(3,3) ;
X = sum(Xs,2);
Y = sum(Ys,2);
Z = sum(Zs,2);
XYZ = [X Y Z];
xyY = XYZToxyY(XYZ')';