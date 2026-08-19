function q_out = smoothen_quat(q_new, q_prev, alpha)
    tol     = 1e-9;     % numerical tolerance
    if dot(q_new, q_prev) < 0
        q_new = -q_new;
    end

    q_out = slerp_unit_quat(q_prev, q_new, alpha);

    q_out = q_out ./ max(norm(q_out), tol);
end

function q = slerp_unit_quat(q0, q1, t)
    q0 = q0(:); q1 = q1(:);
    dot01 = q0.'*q1;
    dot01 = max(min(dot01,1.0), -1.0);

    if (1 - dot01) < 1e-6
        q = (1-t)*q0 + t*q1;
        q = q.' ./ norm(q);
        return;
    end

    theta = acos(dot01);
    s0 = sin((1-t)*theta);
    s1 = sin(t*theta);
    sT = sin(theta);
    q = (s0*q0 + s1*q1) / sT;
    q = q.';
end