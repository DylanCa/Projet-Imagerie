// writing image PGM RAW (8 bits) (PBM)
// usage: writepbm(img,'image.pbm');

function writepbm(image,filename)  
  fd=mopen(filename,'wb');
  s=size(image);
  mputl('P5',fd);
  mputl(string(s(1)),fd);
  mputl(string(s(2)),fd);
  mputl("255",fd);
  
  mput(image,'uc');
  
  mclose();
endfunction


// reading image PGM RAW (8 bits) (PBM)
// usage: img = readpbm('image.pbm');

function image=readpbm(filename)  
  [u,err]=mopen(filename,'rb')
  if err<>0 then error('Error opening file '+filename), end
  if mgetl(u,1)~='P5' error('Unrecognized format'), end
  z=mgetl(u,1), while part(z,1)=='#', z=mgetl(u,1), end
  n=strtod(z)
  z=mgetl(u,1)
  n=[n strtod(z) ]
  mgetl(u,1)
  image=matrix(mget(n(1)*n(2),'uc',u),n)
  mclose(u)
endfunction


// displaying an 8 bites gray level coded image (0..255)
// usage examples:
// display_gray(u); (without zoom)
// display_gray(u,3); (with zoom x3)
// display_gray([u;v]); (2 images side by side)

function display_gray(u,varargin)
  clf()
  xset("colormap",graycolormap(256))
  if size(varargin)==0 then z=1, else z=varargin(1), end
  xset("wdim",size(u,1)*z-1,size(u,2)*z-1)
  xsetech(arect=[0 0 0 0])
  Matplot(u',"020")
endfunction


// ---------------------------------------------------------------------------

function initializeImg()
    imgA1 = readpbm('mA1.pbm');
    imgA2 = readpbm('mA2.pbm');
    imgA3 = readpbm('mA3.pbm');
    imgA41 = readpbm('mA4-1.pbm');
    imgA42 = readpbm('mA4-2.pbm');
    imgB1 = readpbm('mB1.pbm');
    imgB2 = readpbm('mB2.pbm');
    imgB3 = readpbm('mB3.pbm');
    imgX2 = readpbm('mX2.pbm');
    imgU1 = readpbm('mU1.pbm');
    imgU2 = readpbm('mU2.pbm');
endfunction

function missionA1(img)
    maxValue = max(img); // Gets the X and Y coordinates of the brightest pixel of img
    xSize = size(img, 2)
    ySize = size(img, 1)
    
    printf("Searching for the Brightest Pixel ( %d ) ... \n\n", maxValue);
    
    for x = 1:xSize
        for y = 1:ySize
            if img(y,x) == maxValue
                printf("Brightest Pixel Detected ( Coordinates X = %d, Y = %d )\n",x, y);
            end
        end
    end
    
endfunction

function missionA2Fast(img)   
    printf("Gaz level : %.2f%%", mean(img)/2.56)    // Calculates the mean pixel and then divides it by 2.56 in order to get the percentage, then displays it
endfunction

function missionA2Slow(img)
    xSize = size(img, 2) // Takes the x Size of the given image
    ySize = size(img, 1) // Takes the y Size of the given image
    
    matrGaz = []
    for x = 1:xSize // Loop across the matrix
        for y = 1:ySize
            matrGaz(x,y) = (img(y,x)/256)*100 // Calculate the Gas Percentage of every pixel
        end
    end
    printf("Gaz level : %.2f%%",mean(matrGaz)) // Calculates the mean of the percentages and displays it
endfunction

function missionA3(img) // To finish !!!!!!!!!!!
    xSize = size(img, 2)
    ySize = size(img, 1)
    meanPixel = mean(img)
    matrBW = []
    
    for x = 1:xSize
        for y = 1:ySize
            if img(y,x) < meanPixel
                matrBW(y,x) = 255
            else
                matrBW(y,x) = 0
            end
        end
    end
    
    display_gray(matrBW)
endfunction

function matrNewImage = missionA4(img, img2)
    xSize = size(img, 2)
    ySize = size(img, 1)
    
    matrNewImage = []
    
    for x = 1:xSize
        for y = 1:ySize
            
            if ((img(y,x) + img2(y,x))/2) == 127.5
                matrNewImage(y,x) = 0
            elseif(img(y,x) == 0 | img(y,x) == 255) then
                matrNewImage(y,x) = img2(y,x)
            elseif(img2(y,x) == 0 | img2(y,x) == 255) then
                matrNewImage(y,x) = img(y,x)
            else
                matrNewImage(y,x) = img(y,x)
            end
            
        end
    end
    display_gray(matrNewImage)
endfunction

function missionB1(img)
    ratio=255/max(img); // Gets the ratio of the birghtest pixel of the image in order to get a contrast 
    display_gray(img*ratio); // Displays the same image but modified by the ratio
endfunction

function missionB2(img) // TO FINISH !!!!!!!!
    xSize = size(img, 2)
    ySize = size(img, 1)
    
    meanPixel = mean(img)
    matrNewImage = []
    
    for x = 1:xSize
        for y = 1:ySize
            if img(y,x) <= meanPixel
                matrNewImage(y,x) = 0
            else matrNewImage(y,x) = 255
            end
            
        end
    end
    
    display_gray(matrNewImage)
endfunction


// CleaningMode = 1 > Median
// CleaningMode = 2 > Mean
function missionX2(img, intensity, cleaningMode) 
    xSize = size(img, 2)
    ySize = size(img, 1)
    
    o = 1
    p = 1
    
    martMean = []
    
    for x = 1:xSize
        for y = 1:ySize
            if x+intensity <= xSize & y+intensity <= ySize then
                for j = x:x+intensity
                    for i = y:y+intensity
                        martMean(o,p) = img(i,j)
                        o = o +1
                    end
                    o = 1
                    p = p +1
                end
            else 
                if x+intensity >= xSize then
                    for j = x:-1:x-intensity
                        if y+intensity >= ySize then
                                for i = y:-1:y-intensity
                                    martMean(o,p) = img(i,j)
                                    o = o +1
                                end
                                o = 1
                                p = p +1
                         else
                             for i = y:y+intensity
                                martMean(o,p) = img(i,j)
                                o = o +1
                            end
                                o = 1
                                p = p +1
                        end
                    end
                else
                    for j = x:x+intensity
                        if y+intensity >= ySize then
                                for i = y:-1:y-intensity
                                    martMean(o,p) = img(i,j)
                                    o = o +1
                                end
                                o = 1
                                p = p +1
                         else
                             for i = y:y+intensity
                                martMean(o,p) = img(i,j)
                                o = o +1
                            end
                                o = 1
                                p = p +1
                        end
                    end
                end
            end
            
            p = 1
            if cleaningMode == 1
                lowPassImg(y,x) = median(martMean)
            elseif cleaningMode == 2
                lowPassImg(y,x) = mean(martMean)
            end
        end
    end
        
        display_gray(lowPassImg)
endfunction

