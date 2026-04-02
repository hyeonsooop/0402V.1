function h = trim_history(h, T)
fn = fieldnames(h);
for i = 1:numel(fn)
    h.(fn{i}) = h.(fn{i})(1:T,:);
end
