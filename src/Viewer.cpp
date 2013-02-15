/*
 * Viewer.cpp
 * Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
 *
 * Viewer.cpp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Viewer.cpp is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "Viewer.hpp"
#include <boost/bind.hpp>
#include <osgGA/TrackballManipulator>

Viewer::Viewer(int fps) :
    myThread(), myMutex(), myFps(fps)
{
    using namespace osgViewer;
    setThreadSafeReferenceCounting(true);
    setThreadSafeRefUnref(true);
    setCameraManipulator(new osgGA::TrackballManipulator);
}

Viewer::~Viewer()
{
    setDone(true);
    if (myThread) myThread->join();
}

int Viewer::run()
{
    realize();
    myThread.reset(new boost::thread(boost::bind(&Viewer::loop,this)));
    return 0;
}

void Viewer::loop()
{
    while (!done())
    {
        lock();
        frame();
        unlock();
        boost::this_thread::sleep(boost::posix_time::milliseconds(1000/myFps));
    }
}

void Viewer::lock()
{
    myMutex.lock();
}

void Viewer::unlock()
{
    myMutex.unlock();
}

VisCar::VisCar(char* model, char * texture) : car(new Car(std::string(model)))
{
    osg::Group * root = new Frame(1,"N","E","D");
    root->addChild(new Terrain(std::string(texture),osg::Vec3(10,10,0)));
    if (car) root->addChild(car);
    getCameraManipulator()->setHomePosition(osg::Vec3(-3,3,-3),
                                            osg::Vec3(0,0,0),osg::Vec3(0,0,-1));
    if (root) setSceneData(root);
    setUpViewInWindow(0,0,400,400);
    run();
}

// vim:ts=4:sw=4
