#include "Viewer.hpp"
#include "osgUtils.hpp"

#include <osgGA/TrackballManipulator>

#include <boost/date_time/posix_time/posix_time.hpp>
#include <boost/thread/thread.hpp> 

// Static linking of OSG needs special macros
#ifdef OSG_LIBRARY_STATIC
#include <osgDB/Registry>

#if defined(__APPLE__) 
    USE_GRAPICSWINDOW_IMPLEMENTATION(Cocoa) 
#else 
    USE_GRAPHICSWINDOW() 
#endif 

USE_OSGPLUGIN(rgb);
USE_OSGPLUGIN(ac);
#endif

int main(int argc, char * argv[]) {
    if (argc != 2) {
        std::cout << "usage: " << argv[0] << " data_directory" << std::endl;
        return 1;
    }
    std::string dataDir(argv[1]);
    Viewer viewer;
    viewer.setUpViewInWindow(0,0,640,480);
    viewer.setCameraManipulator(new osgGA::TrackballManipulator);
    viewer.getCameraManipulator()->setHomePosition(osg::Vec3d(50,50,-50),osg::Vec3d(0,0,0),osg::Vec3d(0,0,-1),false);

    osg::Group * sceneRoot = new osg::Group;
    viewer.setSceneData(sceneRoot);
    sceneRoot->addChild(new Frame(20,"N","E","D"));
    sceneRoot->addChild(new Terrain(dataDir+"/images/lz.rgb",osg::Vec3d(100,100,100)));

    Plane * plane = new Plane(dataDir+std::string("/models/plane.ac"));
    plane->setPosition(osg::Vec3(0,0,-10));
    plane->addChild(new Frame(15,"X","Y","Z"));
    sceneRoot->addChild(plane);

    viewer.realize();

    for (int i=0;i<1000;i++) {
        viewer.frame();
        boost::this_thread::sleep(boost::posix_time::milliseconds(1));
        float t= i/1000.0;
        float period = 1; // seconds
        float phi = 0.5*sin(2*M_PI/period*t);
        float theta = 0.5*sin(2*M_PI/period*t);
        float psi = 0.5*sin(2*M_PI/period*t);
        float throttle = 0.5*sin(2*M_PI/period*t);	
        float aileron = 0.5*sin(2*M_PI/period*t);
        float elevator = 0.5*sin(2*M_PI/period*t);
        float rudder = 0.5*sin(2*M_PI/period*t);
        float pN = 10*sin(2*M_PI/period*t);
        float pE = 10*cos(2*M_PI/period*t);
        float pD = -(10+10*sin(2*M_PI/period*t));
        plane->setPosition(osg::Vec3(pN,pE,pD));
        plane->setEuler(phi,theta,psi);
        plane->setU(throttle,aileron,elevator,rudder);
    }

    return 0;
}

// vim:ts=4:sw=4
