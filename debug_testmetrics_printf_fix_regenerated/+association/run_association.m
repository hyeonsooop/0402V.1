function [assoc, ris_assign] = run_association(cfg, net)
%RUN_ASSOCIATION Wrapper for Algorithm 1 and 2.
assoc = core.algorithm1_association_clustering(cfg, net);
ris_assign = core.algorithm2_ris_assignment(cfg, net, assoc);
end
