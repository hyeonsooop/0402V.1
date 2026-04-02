function ris_assign = algorithm2_ris_assignment(cfg, net, assoc)
% Each SSF is associated to the user that maximizes reflected-link strength.
R = cfg.R; Ns = cfg.Ns; K = cfg.K; Nc = cfg.Nc;
Uten = false(R, Ns, K, Nc);
for r = 1:R
    for ns = 1:Ns
        bestScore = -inf;
        bestk = 1; besti = 1;
        for k = 1:K
            for i = 1:Nc
                u = assoc.order(k,i);
                score = 0;
                for b = find(assoc.C(u,:))
                    score = score + norm(net.ch.bs_ris{b,r},'fro')^2 * norm(net.ch.ris_ue{r,u},'fro')^2;
                end
                if score > bestScore
                    bestScore = score; bestk = k; besti = i;
                end
            end
        end
        Uten(r,ns,bestk,besti) = true;
    end
end
ris_assign.U = Uten;
end
