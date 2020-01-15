function [image] = recons(nxrs,theta,sinogram)
    image = iradon(sinogram,theta,'linear','Hamming',1,nxrs);
end

