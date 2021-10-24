FROM ros:melodic-robot

SHELL ["/bin/bash","-c"]
ENV CATKIN_WS=/root/catkin_ws
RUN mkdir -p $CATKIN_WS/src

# install ros package
RUN apt-get update && apt-get install -y \
    git \
    iputils-ping \
    ros-${ROS_DISTRO}-ros-control ros-${ROS_DISTRO}-ros-controllers \
    ros-${ROS_DISTRO}-moveit ros-${ROS_DISTRO}-industrial-core ros-${ROS_DISTRO}-gazebo-ros-control

# install other packages
RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
    && cd $CATKIN_WS \
    && git clone -b melodic-devel https://github.com/ros-industrial/universal_robot.git src/universal_robot \
    && git clone -b kinetic-devel https://github.com/ros-industrial/ur_modern_driver.git src/ur_modern_driver \
    && git clone -b v0.6.0 https://github.com/Unity-Technologies/ROS-TCP-Endpoint src/ros_tcp_endpoint \
    && git clone https://github.com/adamleon/cartesian_controllers.git src/cartesian_controllers \
    && rosdep install --from-paths . --ignore-src --rosdistro ${ROS_DISTRO} \
    # building
    && catkin_make -DCMAKE_BUILD_TYPE=Release

# setup environment
RUN touch /root/.bashrc \
    && echo ". /opt/ros/${ROS_DISTRO}/setup.bash" >> /root/.bashrc \
    && cd $CATKIN_WS \
    && echo ". ${CATKIN_WS}/devel/setup.bash" >> /root/.bashrc \
    && rm -rf /var/lib/apt/lists/*

COPY launch /root