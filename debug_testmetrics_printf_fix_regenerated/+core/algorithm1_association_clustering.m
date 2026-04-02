function assoc = algorithm1_association_clustering(cfg, net)
% Paper-guided partial coordination + MFCF clustering.
U = cfg.U; B = cfg.B; K = cfg.K; Nc = cfg.Nc;
assoc.C = false(U, B);

% Step 1: partial coordination via max-SINR-like score.
for u = 1:U
    score = -inf(1,B);
    for b = 1:B
        h = net.ch.bs_ue{b,u};
        g = net.ch.ue_bs{u,b};
        dl = norm(h,'fro')^2;
        ul = norm(g,'fro')^2;
        score(b) = dl + ul;
    end
    [~, idx] = maxk(score, cfg.Mc);
    assoc.C(u, idx) = true;
end

% Step 2: NOMA clustering via channel correlation + distance.
clusters = zeros(K, Nc);
unused = 1:U;
for k = 1:K
    if isempty(unused), break; end
    head_scores = zeros(1,numel(unused));
    for ii = 1:numel(unused)
        u = unused(ii);
        for b = find(assoc.C(u,:))
            head_scores(ii) = head_scores(ii) + norm(net.ch.bs_ue{b,u},'fro')^2;
        end
    end
    [~, hm] = max(head_scores);
    head = unused(hm);
    unused(unused==head) = [];

    mate = head;
    if ~isempty(unused)
        cand_scores = zeros(1,numel(unused));
        for ii = 1:numel(unused)
            u2 = unused(ii);
            corr_sum = 0;
            bslist = find(assoc.C(head,:) | assoc.C(u2,:));
            for b = bslist
                h1 = net.ch.bs_ue{b,head};
                h2 = net.ch.bs_ue{b,u2};
                corr_sum = corr_sum + abs(h1*h2')/(norm(h1)*norm(h2)+1e-12);
            end
            d = norm(net.ue_pos(head,:) - net.ue_pos(u2,:));
            dmax = norm(cfg.area_xy);
            cand_scores(ii) = cfg.beta1 * corr_sum + cfg.beta2 * (1 - d/dmax);
        end
        [~, midx] = max(cand_scores);
        mate = unused(midx);
        unused(unused==mate) = [];
    end
    clusters(k,:) = [head, mate];
end

% beam/user ordering by effective channel gain, descending.
order = clusters;
for k = 1:K
    gains = zeros(1,Nc);
    for i = 1:Nc
        u = clusters(k,i);
        for b = find(assoc.C(u,:))
            gains(i) = gains(i) + norm(net.ch.bs_ue{b,u},'fro')^2;
        end
    end
    [~, idx] = sort(gains, 'descend');
    order(k,:) = clusters(k,idx);
end
assoc.clusters = clusters;
assoc.order = order;
end
