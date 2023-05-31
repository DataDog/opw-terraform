# AWS
This manifest will create a production-ready Observability Pipelines (OP) cluster in a specified VPC. This is inclusive of the necessary tools for disk buffers, load-balancing, and autoscaling, as seen below:

![A diagram of the components created by this manifest](./d2.png)

**A note on persistence:** This manifest does create EBS drives for disk buffers. However, since they are created by the AutoScaling Group, they will be destroyed during scale-down events or if the associated instance is terminated.