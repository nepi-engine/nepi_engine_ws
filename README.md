# nepi_engine_ws
Top-level repository for nepi-engine development

You are in the _default_ branch. There is not a lot here... the first thing you must decide is whether to checkout a _ROS 1_ branch or a _ROS 2_ branch. Then you can checkout the appropriate ROS-specific main branch with

```
$ git checkout <rosx>_main
```
where \<rosx\> should be replaced with _ros1_ or _ros2_ as applicable.

At that point, follow the instructions in the top-level README to deploy code, build on the target hardware, etc.

## What about doing cross development for _ROS 1_ and _ROS 2_?
Generally, it will be a big headache to try to work on both branches from the same repository folder, so if you need to work on both, we recommend that you clone this repository twice and checkout different ROS-specific branches in each of the copies.

