function filloval(x,y,rx,ry)function filloval(x,y,rx,ry)
    hold on
    th = 0:pi/50:2*pi;
    xc = rx * cos(th) + x;
    yc = ry * sin(th) + y;
    fill(xc,yc,'r','EdgeColor','none','FaceAlpha',0.4);
    hold off
end
    hold on
    th = 0:pi/50:2*pi;
    xc = rx * cos(th) + x;
    yc = ry * sin(th) + y;
    fill(xc,yc,'r','EdgeColor','none','FaceAlpha',0.4);
    hold off
end