(*Trivial facts that would clutter up the other files*) 
Require Import ssreflect.
From mathcomp Require Import ssreflect seq ssrnat.
From istari Require Import Sigma Tactics
     Syntax Subst SimpSub Promote Hygiene
     ContextHygiene Equivalence Equivalences Rules Defined PageType lemmas0 derived_rules.


Definition U0 : (term obj) := univ nzero.

Lemma subst_nat: forall s,
    @ subst obj s nattp = nattp.
  intros. unfold nattp. auto. Qed.

Hint Rewrite subst_nat: core subst1.

Ltac weaken H := eapply tr_formation_weaken; apply H.
Ltac var_solv0 := try (apply tr_hyp_tm; repeat constructor).

Hint Rewrite subst_nat: core subst1.

Ltac var_solv' := unfold oof; match goal with |- tr ?G' (deq (var ?n) ?n' ?T) => try
                                 rewrite - (subst_nat (sh (n.+1))); var_solv0 end.

Lemma equiv_arrow :
  forall (m m' n n' : term obj),
    equiv m m'
    -> equiv n n'
    -> equiv (arrow m n) (arrow m' n').
Proof.
prove_equiv_compat.
Qed.

Lemma nat_U01 G: tr ((hyp_tm booltp)::G) (oof (bite (var 0) voidtp unittp) U0).
change U0 with (subst1 (var 0) U0).
apply tr_booltp_elim. change booltp with (@subst obj (sh 1) booltp). var_solv0. apply tr_voidtp_formation. apply tr_unittp_formation.
Qed.


Lemma nat_U0: forall G,
    tr G (oof nattp U0). Admitted.
Hint Resolve nat_U0. 

Lemma nat_type: forall G,
      tr G (deqtype nattp nattp). Admitted.
Hint Resolve nat_type. 
Lemma unit_type: forall G,
      tr G (deqtype unittp unittp). Admitted.
Hint Resolve unit_type. 

Lemma nsucc_type G n m:
  tr G (deq n m nattp) ->
  tr G (deq (nsucc n) (nsucc m) nattp). Admitted.
Hint Resolve nsucc_type. 

Definition leq_t n m : term obj :=
  app (app leqtp n) m.

Definition lt_t n m : term obj :=
  app (app lttp n) m.

Lemma zero_typed: forall G,
    tr G (oof nzero nattp). Admitted.

Lemma leq_refl: forall G n,
    tr G (deq n n nattp) ->
    tr G (oof triv (leqpagetp n n)). Admitted.

Lemma leq_type: forall G n1 n2,
    tr G (oof n1 nattp) -> tr G (oof n2 nattp) ->
    tr G (oof (leq_t n1 n2) U0).
  Admitted.


Lemma lt_type: forall G n1 n2,
    tr G (oof n1 nattp) -> tr G (oof n2 nattp) ->
    tr G (oof (ltpagetp n1 n2) U0).
  Admitted.


Lemma U0_type: forall G,
    tr G (deqtype U0 U0). Admitted.

Hint Resolve nat_type nat_U0 zero_typed leq_refl leq_type lt_type U0_type.

Definition if_z (n: term obj): (term obj) := ppi1 n.


Lemma if_z_typed n G : tr G (oof n nattp) -> tr G (oof (if_z n) booltp).
Admitted.

(*n1 <= n2*)
 Definition leq_b n1 := app (wind (lam (* x = 0*)
                             (lam (*x = 1, y= 0*)
                                ( lam
                                    ( (*x = 2, y = 1, z = 0*)
                                      bite (var 2) (*if n1 = 0*)
                                           (lam (*x = 3, y = 2, z = 1, n2 = 0*)
                                             btrue) 
                                           ( 
                                             lam
                                               ( (*x = 3, y = 2, z = 1, n2 = 0*)
                                                 bite (if_z (var 0))
                                                      bfalse
                                                      (app (app (var 1) triv) (app (ppi2 (var 0)) triv))
                                               )
                                           )
                                    )
                                )
                             )                           
                            )) n1.


Definition ltb_app n1 n2 := app (leq_b (nsucc n1)) n2.

(*should be fine*)
Lemma ltapp_typed G m n: tr G (oof m nattp) -> tr G (oof n nattp) ->
  tr G (oof (ltb_app m n) booltp). Admitted.

(*more difficult, need induction*)
Lemma ltb_false G n : tr G (oof n nattp) -> tr G (deq (ltb_app n n) bfalse booltp).
Admitted.

Lemma nsucc_lt: forall G n, tr G (oof n nattp) ->
                       tr G (oof triv (lt_t n (nsucc n))).
Admitted.

Definition eq_b n1 := app (wind (lam (* x = 0*)
                             (lam (*x = 1, y= 0*)
                                ( lam
                                    ( (*x = 2, y = 1, z = 0*)
                                      bite (var 2)
                                           (lam (*x = 3, y = 2, z = 1, n2 = 0*)
                                              (if_z (var 0))
                                           ) (*first one is zero*)
                                           ( (*first one is nonzero*)
                                             lam
                                               ( (*x = 3, y = 2, z = 1, n2 = 0*)
                                                 bite (if_z (var 0))
                                                      bfalse
                                                      (app (app (var 1) triv) (app (ppi2 (var 0)) triv))
                                               )
                                           )
                                    )
                                )
                             )                           
                          )) n1.

Lemma eq_b_succ n1 n2: equiv (app (eq_b (nsucc n1)) n2) (bite (if_z n2)
                                                      bfalse
                                                      (app (eq_b n1) (app (ppi2 n2) triv))).
  intros.
  unfold eq_b. unfold wind.
  eapply equiv_trans.
  {
    apply equiv_app.
    { apply equiv_app.
      { apply steps_equiv. apply theta_fix. }
      {apply equiv_refl. }
    }
    {apply equiv_refl. }
  }
  {
  eapply equiv_trans.
  {
    apply equiv_app.
    { apply equiv_app.
      { apply reduce_equiv. apply reduce_app_beta; apply reduce_id.
      }
      {apply equiv_refl. }
    }
    {apply equiv_refl. }
  }
  {
    simpsub. simpl. simpsub.
    eapply equiv_trans.
  {
    apply equiv_app.
    { apply reduce_equiv. apply reduce_app_beta; apply reduce_id.
      }
      {apply equiv_refl. }
    }
  { simpsub. simpl.
    eapply equiv_trans.
    {
      apply equiv_app.
      {
        apply equiv_app.
        {
          apply equiv_app.
          {
            apply reduce_equiv. apply reduce_app_beta. apply reduce_id.
            unfold nzero. apply reduce_ppi1_beta. apply reduce_id.
          }
          {
            unfold nsucc. apply reduce_equiv. apply reduce_ppi2_beta. apply reduce_id.
          }
        }
        apply equiv_refl.
      }
      {apply equiv_refl. }
    }
    { simpsub. simpl.
    eapply equiv_trans.
    {
      apply equiv_app.
      {
        apply equiv_app.
        {
          apply reduce_equiv. apply reduce_app_beta; apply reduce_id.
        }
        { apply equiv_refl.
        }
      }
      {apply equiv_refl. }
    }
    { simpsub. simpl.
      eapply equiv_trans.
      { apply equiv_app.
        apply reduce_equiv. apply reduce_app_beta.
        apply reduce_bite_beta2. apply reduce_id.
        apply reduce_id.
        {apply equiv_refl. }
      }
      {
        simpsub.
        simpl.
        {eapply equiv_trans.
         { apply reduce_equiv.
           apply reduce_app_beta; apply reduce_id. }
           {
             simpsub. simpl.
             apply equiv_bite.
             - apply equiv_refl.
             - apply equiv_refl.
             - apply equiv_app.
               { eapply equiv_trans. 
                 { apply reduce_equiv. apply reduce_app_beta;
                   apply reduce_id. (*?*)
                 }
                 {simpsub. simpl.
                  apply equiv_app.
                  - apply equiv_refl.
                  - unfold nsucc.
                    eapply equiv_trans.
                    apply equiv_app.
                    apply reduce_equiv. apply reduce_ppi2_beta;
                                          apply reduce_id. apply equiv_refl.
                    apply reduce_equiv.
                    replace n1 with (subst1 triv (subst sh1 n1)).
                    apply reduce_app_beta. simpsub. apply reduce_id.
                    apply reduce_id.
                    simpsub. auto.
                 }
               }
               apply equiv_refl.
           }
           } } } } } } }
Qed.


Lemma eq_b0 n2: equiv (app (eq_b nzero) n2) (if_z n2).
  unfold eq_b. unfold wind.
  eapply equiv_trans.
  {
    apply equiv_app.
    { apply equiv_app.
      { apply steps_equiv. apply theta_fix. }
      {apply equiv_refl. }
    }
    {apply equiv_refl. }
  }
  {
  eapply equiv_trans.
  {
    apply equiv_app.
    { apply equiv_app.
      { apply reduce_equiv. apply reduce_app_beta; apply reduce_id.
      }
      {apply equiv_refl. }
    }
    {apply equiv_refl. }
  }
  {
    simpsub. simpl. simpsub.
    eapply equiv_trans.
  {
    apply equiv_app.
    { apply reduce_equiv. apply reduce_app_beta; apply reduce_id.
      }
      {apply equiv_refl. }
    }
  { simpsub. simpl.
    eapply equiv_trans.
    {
      apply equiv_app.
      {
        apply equiv_app.
        {
          apply equiv_app.
          {
            apply reduce_equiv. apply reduce_app_beta. apply reduce_id.
            unfold nzero. apply reduce_ppi1_beta. apply reduce_id.
          }
          {
            unfold nzero. apply reduce_equiv. apply reduce_ppi2_beta. apply reduce_id.
          }
        }
        apply equiv_refl.
      }
      {apply equiv_refl. }
    }
    { simpsub. simpl.
    eapply equiv_trans.
    {
      apply equiv_app.
      {
        apply equiv_app.
        {
          apply reduce_equiv. apply reduce_app_beta; apply reduce_id.
        }
        { apply equiv_refl.
        }
      }
      {apply equiv_refl. }
    }
    { simpsub. simpl.
      eapply equiv_trans.
      { apply equiv_app.
        apply reduce_equiv. apply reduce_app_beta.
        apply reduce_bite_beta1. apply reduce_id.
        apply reduce_id.
        {apply equiv_refl. }
      }
      {
        simpsub. unfold if_z. apply reduce_equiv.
        replace (ppi1 n2) with (subst1 n2 (ppi1 (var 0))).
        2: {
          simpsub. auto.
        }
        apply reduce_app_beta; apply reduce_id.
      }
    }
    }
    
  }
  }
  }
  Qed.


Lemma w_elim_hyp G1 G2 a b J :
  tr G1 (deqtype a a) ->
      tr (cons (hyp_tm a) G1) (deqtype b b) ->
      tr (G2 ++ hyp_tm (sigma a (arrow b (subst sh1 (wt a b)))) :: G1) J
      -> tr (G2 ++ hyp_tm (wt a b) :: G1) J.
  intros. eapply tr_subtype_convert_hyp; unfold dsubtype;
  change triv with (@shift obj 1 triv);
  change (subtype
       (subst sh1 ?one)
       (subst sh1 ?sigma)) with
      (subst sh1 (subtype one sigma)) (*ask karl if i write shift here it doesnt work*); try rewrite ! subst_sh_shift;
    try apply tr_weakening_append1. apply tr_wt_subtype_sigma; auto.
  apply tr_wt_sigma_subtype; auto.
  assumption.
Qed.




Lemma eqb_typed {G} n1:
  tr G (oof n1 nattp) ->
  tr G (oof (eq_b n1) (arrow nattp booltp)).
  intros.
  change (arrow nattp booltp) with (subst1 n1 (arrow nattp booltp)).
  apply (tr_wt_elim _ booltp (bite (var 0) voidtp unittp)).
  - assumption.
  - simpsub. simpl.
    rewrite make_app2.
     change (lam (if_z (var 0))) with
      (subst (under 2 sh1)  (lam (if_z (var 0)))).
    change (lam
             (bite (if_z (var 0)) bfalse
                (app (app (var 1) triv)
                     (app (ppi2 (var 0)) triv)))) with
        (subst (under 2 sh1)
(lam (bite (if_z (var 0)) bfalse
                (app (app (var 1) triv)
                     (app (ppi2 (var 0)) triv))))
        ).
    apply tr_booltp_eta_hyp; simpsub; simpl; simpsub;
    (*rewrite ! subst_nat; *)
      apply tr_arrow_intro; auto; try weaken tr_booltp_formation.
    + apply if_z_typed. var_solv'.
    + apply (w_elim_hyp _ [::]).
      weaken tr_booltp_formation. weaken nat_U01.
      match goal with |- tr ?G (deq ?M ?M ?A) => change M with
       (@subst obj (under 0 (dot (ppi2 (var 0)) (dot (ppi1 (var 0)) sh1)))
       (bite (var 1) bfalse
          (app (app (var 2) triv)
               (app (var 0) triv)))) end.
      apply tr_sigma_eta_hyp.
      simpsub. simpl.
          change (app (app (var 2) triv)
                      (app (var 0) triv)) with
              (@subst obj (under 1 sh1)
                     (app (app (var 1) triv)
                          (app (var 0) triv))).
          change bfalse with (@subst obj (under 1 sh1) bfalse).
          rewrite make_app1.
          apply tr_booltp_eta_hyp; simpsub.
      * constructor.
      * eapply tr_compute_hyp.
        {
          constructor. apply equiv_pi. apply reduce_equiv.
          apply reduce_bite_beta2. apply reduce_id.
          apply equiv_refl.
        }
        simpl. eapply (tr_compute_hyp _ [::]).
        {
          constructor. apply equiv_arrow. apply reduce_equiv.
          apply reduce_bite_beta2. apply reduce_id.
          apply equiv_refl.
        }
        simpl.
        apply (tr_arrow_elim _ nattp); auto. weaken tr_booltp_formation.
        change (arrow nattp booltp) with (@subst1 obj triv (arrow nattp booltp)). 
        apply (tr_pi_elim _ (unittp)).
        - change (pi unittp (arrow nattp booltp))
          with (@subst obj (sh 2) (pi unittp (arrow nattp booltp))).
        var_solv0. constructor.
        - apply (tr_arrow_elim _ unittp); auto. 
          change (arrow unittp nattp) with (@subst obj (sh 1) (arrow
                                                                 unittp nattp)).
          var_solv0.
          constructor.
Qed.


Definition nat_ind_fn : (term obj) := lam (lam (lam (lam (*P = 3 BC = 2 IS = 1 x = 0 *)
                                          (app (
                                            wind ( lam (lam (lam ( (*c = 0, b= 1, a = 2, x = 3, IS = 4, BC = 5,
                                                                    P = 6*)
                                                                 bite (var 2) (var 5)
                                                                      (app (app (var 4)
                                                                           (app (var 1) triv))
                                                                           (app (var 0) triv))
                          )))))                
                                               (var 0)
                                          )
                                               ))).

Definition nat_elim G := (tr_wt_elim G booltp (bite (var 0) voidtp unittp)).

Lemma tr_wt_intro :
    forall G a b m m' n n',
      tr G (deq m m' a)
      -> tr G (deq n n' (subst1 m (arrow b (subst sh1 (wt a b)))))
      -> tr (cons (hyp_tm a) G) (deqtype b b)
      -> tr G (deq (ppair m n) (ppair m' n') (wt a b)).
  Admitted.

Ltac simpsub1 :=
autounfold with subst1; autorewrite with subst1.

Ltac simpsub_big := repeat (simpsub; simpsub1).


Hint Unfold subst1: subst1.

Lemma eqapp_typed G m n: tr G (oof m nattp) -> tr G (oof n nattp) ->
  tr G (oof (app (eq_b m) n) booltp). Admitted.

          Lemma subst_eqb s n: subst s (eq_b n) = eq_b (subst s n).
  intros. unfold eq_b. simpsub. auto. Qed.
          Hint Rewrite subst_eqb: core subst1.

  Lemma nat_ind G : tr G (oof nat_ind_fn
                              (pi (arrow nattp U0)
                                  (pi (app (var 0) nzero)
                                         (pi (pi nattp
                                                    (
                                                      arrow (app (var 2) (var 0))
                                                            (app (var 2) (nsucc (var 0)))
                                                           )
                                                )
                                                (pi nattp
                                                    (app (var 3) (var 0))
                                                )
                                         )
                                  )
                         )).
    intros.
    assert (forall G2 x y, tr (G2 ++ (hyp_tm (arrow nattp U0) :: G))
                       (deq x y nattp) ->
        (tr (G2 ++ (hyp_tm (arrow nattp U0) :: G))
            (deqtype (app (var (length G2)) x) (app (var (length G2)) y)))) as Hp.
    intros.
      eapply tr_formation_weaken. apply (tr_arrow_elim _ nattp); auto.
      apply U0_type.
change (arrow (nattp) (univ nzero)) with
    (@subst obj (sh (length G2)) (arrow nattp (univ nzero))). change (var (length G2)) with (@subst obj (sh (length G2)) (var 0)). rewrite ! subst_sh_shift. apply tr_weakening_append.
change (arrow (nattp) (univ nzero)) with
    (@subst obj (sh 1) (arrow nattp (univ nzero))). var_solv0.
    simpl.
    apply tr_pi_intro. apply tr_arrow_formation; auto.
    apply tr_pi_intro; auto.
    + apply (Hp [::]); auto.
  (*  + apply tr_arrow_formation; auto. apply tr_pi_formation; auto.
      apply tr_arrow_formation; auto.
      rewrite make_app1. eapply Hp; auto. simpl. var_solv'.
      rewrite make_app1. eapply Hp; simpl; auto. apply nsucc_type. var_solv'.
      apply tr_pi_formation; auto.
      rewrite make_app1. eapply Hp; auto. simpl. var_solv'.*)
    + apply tr_pi_intro; auto.
      - apply tr_pi_formation; auto. apply tr_arrow_formation; auto.
      rewrite make_app2. eapply Hp; auto. simpl. var_solv'.
      rewrite make_app2. eapply Hp; simpl; auto. apply nsucc_type. var_solv'.
      - apply tr_pi_intro; auto. change (app (var 3) (var 0)) with
                                     (@subst1 obj (var 0) (app (var 4) (var 0))).
        eapply nat_elim. fold (@nattp obj). var_solv'.
        change (var 5) with (@subst obj (under 2 sh1) (var 4)).
        change (app (app (var 4) (app (var 1) triv))
                    (app (var 0) triv)) with (@subst obj (under 2 sh1)
(app (app (var 3) (app (var 1) triv))
                    (app (var 0) triv)) 
                                             ).
        rewrite make_app2. apply tr_booltp_eta_hyp. (*true case*) 
        { repeat (simpl; simpsub). rewrite make_app1.
          eapply tr_compute_hyp.
        {
          constructor. apply equiv_arrow. apply reduce_equiv.
          apply reduce_bite_beta1. apply reduce_id.
          apply equiv_refl.
        }
        simpl. eapply (tr_compute_hyp _ [::]).
        {
          constructor. apply equiv_pi. apply reduce_equiv.
          apply reduce_bite_beta1. apply reduce_id.
          apply equiv_refl.
        }
        simpl.
        apply (tr_eqtype_convert _#3 (app (var 5) nzero)).
        { 
          rewrite make_app5. apply Hp.
          unfold nzero. apply tr_wt_intro. constructor.
          simpsub. eapply tr_compute.
          apply equiv_arrow. apply reduce_equiv.
          apply reduce_bite_beta1. apply reduce_id.
          apply equiv_refl. apply equiv_refl. apply equiv_refl.
          apply (tr_transitivity _ _ (lam (app (subst sh1 (var 1)) (var 0))) ).
          {
            simpsub. simpl. apply tr_arrow_intro; auto.
            - weaken tr_voidtp_formation.
              apply (tr_voidtp_elim _ (var 0) (var 0)).
              change voidtp with (@subst obj (sh 1) voidtp).
              var_solv0.
          }
          apply tr_symmetry. apply tr_arrow_eta.
          change 
            (arrow voidtp nattp)
            with (@subst obj (sh 2)
            (arrow voidtp nattp)
                 ). var_solv0.
          apply tr_booltp_elim_eqtype. change booltp with (@subst obj (sh 1) booltp). var_solv0. weaken tr_voidtp_formation. weaken tr_unittp_formation. }
        change (app (var 5) nzero) with
            (@subst obj (sh 5) (app (var 0) nzero)). var_solv0. }
        (*false case*)
        { repeat (simpl; simpsub). rewrite make_app1.
          eapply tr_compute_hyp.
        {
          constructor. apply equiv_arrow. apply reduce_equiv.
          apply reduce_bite_beta2. apply reduce_id.
          apply equiv_refl.
        }
        simpl. eapply (tr_compute_hyp _ [::]).
        {
          constructor. apply equiv_pi. apply reduce_equiv.
          apply reduce_bite_beta2. apply reduce_id.
          apply equiv_refl.
        }
        simpl.
        apply (tr_eqtype_convert _#3 (app (var 5) (ppair bfalse
                                                         (lam (app (var 2) triv))
              ))).
        rewrite make_app5. apply Hp. apply tr_wt_intro; auto. constructor.
        (*b = \x.b * *)
        {
          simpsub.
          eapply tr_compute. apply equiv_arrow.
           apply reduce_equiv.
           apply reduce_bite_beta2. apply reduce_id. apply equiv_refl. apply equiv_refl.
           apply equiv_refl.
          simpsub. simpl. 
          apply (tr_transitivity _ _
                                           (lam (app (var 2) (var 0)))
                          ).
          {
            apply tr_arrow_intro; auto.
            apply (tr_arrow_elim _ unittp); auto.
            match goal with |- tr ?G (deq ?M ?M ?T) =>
                                                      change T with
       (@subst obj (sh 3)                                   
       (arrow unittp
          (wt booltp
              (bite (var 0) voidtp unittp)))) end. var_solv0.
          apply tr_symmetry. apply tr_unittp_eta.
          change unittp with (@subst obj (sh 1) unittp). var_solv0.
          }
          {
            apply tr_symmetry.
            apply tr_arrow_eta.
            match goal with |- tr ?G (deq ?M ?M ?T) =>
                                                      change T with
       (@subst obj (sh 2)                                   
       (arrow unittp
          (wt booltp
              (bite (var 0) voidtp unittp)))) end. var_solv0.
          }
        }
        weaken nat_U01.
        (* IS (b triv ) (c triv) : P (succ (b triv )) *)
        apply (tr_arrow_elim _ (app (var 5) (app (var 1) triv))).
          * rewrite make_app5. apply Hp.
            apply (tr_arrow_elim _ unittp); auto. 
            change (arrow unittp nattp) with (@subst obj (sh 2)
                                                     (arrow unittp nattp)).
            var_solv0. constructor.
            rewrite make_app5. apply Hp.
            change (ppair bfalse (lam (app (var 2) triv))) with
                (@nsucc obj (app (var 1) triv)).
            apply nsucc_type.
            apply (tr_arrow_elim _ unittp); auto.
            change (arrow unittp nattp) with (@subst obj (sh 2)
                                                     (arrow unittp nattp)).
            var_solv0. constructor.
            match goal with |- tr ?G (deq ?M ?M ?T) => change T with
                (@subst1 obj (app (var 1) triv)
                (arrow (app (var 6) (var 0))
          (app (var 6)
               (ppair bfalse (lam (var 1)))))
                ) end.
            apply (tr_pi_elim _ nattp).
            match goal with |- tr ?G (deq ?M ?M ?T) => change T with
                (@subst obj (sh 4)
       (pi nattp
          (arrow (app (var 2) (var 0))
             (app (var 2)
                  (ppair bfalse (lam (var 1))))))) end.
            var_solv0.
            apply (tr_arrow_elim _ unittp); auto.
            change (arrow unittp nattp) with (@subst obj (sh 2)
                                                     (arrow unittp nattp)).
            var_solv0. constructor.
            change (app (var 5) (app (var 1) triv)) with (@subst1 obj triv
(app (var 6) (app (var 2) (var 0)))
                                                         ).
            apply (tr_pi_elim _ unittp). 
            change (pi unittp (app (var 6) (app (var 2) (var 0))))
              with (@subst obj (sh 1)
(pi unittp (app (var 5) (app (var 1) (var 0))))
                   ). var_solv0.
            constructor. }
            Qed.

  Lemma nat_ind_app G P BC IS: tr G (oof P (arrow nattp U0)) ->
                        tr G (oof BC (app P nzero)) ->
                        tr G (oof IS
                                  (pi nattp
                                      (arrow (app (shift 1 P) (var 0))
                                             (app (shift 1 P) (nsucc (var 0)))
                                  ))) ->
                              tr G (oof (app (app (app nat_ind_fn P) BC
                                   ) IS)
                                                (pi nattp
                                                    (app (shift 1 P) (var 0))
                                   )).
    intros.
    replace (pi nattp (app (shift 1 P) (var 0))) with
        (subst1 IS
(pi nattp (app (shift 2 P) (var 0)))
        ).
    2:{
      rewrite - ! subst_sh_shift. simpsub. unfold subst1. auto.
    }
    apply (tr_pi_elim _
           (pi nattp
             (arrow (app (shift 1 P) (var 0))
                      (app (shift 1 P) (nsucc (var 0))))
          )).
    match goal with |- tr ?G (deq ?T ?T ?A) =>
                    replace A with
        (subst1 BC
       (pi
          (pi nattp
             (arrow (app (shift 2 P) (var 0))
                (app (shift 2 P)
                   (nsucc (var 0)))))
          (pi nattp
             (app (shift 3 P) (var 0))))) end.
    2:{ unfold nsucc.
      rewrite - ! subst_sh_shift. simpsub. unfold subst1. 
      simpsub. auto.
    }
    apply (tr_pi_elim _ (app P nzero)).
    match goal with |- tr ?G (deq ?T ?T ?A) =>
                    replace A with (subst1 P
       (pi (app (var 0) nzero)
          (pi
             (pi nattp
                (arrow
                   (app (var 2)
                      (var 0))
                   (app (var 2)
                      (nsucc (var 0)))))
             (pi nattp
                 (app (var 3) (var 0)))))) end.
    eapply tr_pi_elim; try apply nat_ind; auto.
    unfold nsucc. unfold nzero. simpsub. rewrite - ! subst_sh_shift. simpl.
    auto. assumption. assumption.
  Qed.


Hint Rewrite <- subst_sh_shift: core subst1.

  Lemma nat_ind_lamapp G P BC IS IS_type: tr G (oof (lam P) (arrow nattp U0)) ->
                                  tr G (oof BC (subst1 nzero P)) ->
                                  IS_type = (subst1 (nsucc (var 0)) (subst (under 1 (sh 1)) P)) ->
                        tr G (oof IS
                                  (pi nattp
                                      (arrow P IS_type
                                             
                                  ))) ->
                              tr G (oof (app (app (app nat_ind_fn (lam P)) BC
                                   ) IS)
                                                (pi nattp
                                                    P)).
    intros.
    -
      replace P with (subst1 (var 0) (subst (under 1 (sh 1)) P)) at 2.
      2:{ simpsub_big. auto. rewrite - {2} (subst_id obj P).
          apply subst_eqsub. apply eqsub_symm. apply eqsub_expand_id. }
      eapply tr_compute.
apply equiv_symm. apply equiv_pi. apply equiv_refl.
apply reduce_equiv. apply reduce_app_beta; apply reduce_id.
apply equiv_refl. apply equiv_refl.
rewrite - subst_lam subst_sh_shift.
apply nat_ind_app; try assumption.
    - eapply tr_compute.  apply reduce_equiv; try apply reduce_app_beta;
                            apply reduce_id. apply equiv_refl. apply equiv_refl. assumption.
    - eapply tr_compute. apply equiv_pi. apply equiv_refl.
      apply equiv_arrow; rewrite - subst_sh_shift subst_lam; apply reduce_equiv; apply reduce_app_beta; apply reduce_id. apply equiv_refl. apply equiv_refl.
      replace (subst1 (var 0) (subst (under 1 (sh 1)) P)) with P.
      2:{ simpsub_big. auto. rewrite - {1}  (subst_id obj P).
          apply subst_eqsub. apply eqsub_expand_id. }
      subst. assumption.
Qed.



      
Lemma subst_U0: forall s,
    (@ subst obj s (univ nzero)) = univ nzero.
  auto. Qed.
Hint Rewrite subst_U0: core subst1.

Lemma subst_nzero: forall s,
    @ subst obj s nzero = nzero.
  intros. unfold nzero. auto. Qed.
Hint Rewrite subst_nzero: core subst1.

Lemma equiv_equal :
  forall (m m' n n' t t' : term obj),
    equiv t t' ->
    equiv m m'
    -> equiv n n'
    -> equiv (equal t m n) (equal t' m' n').
Proof.
prove_equiv_compat.
Qed.



      Definition eqb_sound_fn :=
    (app (app (app nat_ind_fn (lam
                  (pi nattp
                      ( (*x = 1, y = 0*)
                        arrow 
                        (equal booltp (app (eq_b (var 1)) (var 0)) btrue
                               )
                        (equal nattp (var 1) (var 0))
                  )
               )))
               (lam (*y : nat*)
                  (lam  (*hyp : eqb 0 y  = tt*)
                  triv 
                  )
               ))
               (lam (*x : nat*) (lam (*IH: P(x) ie pi y (eqb x y = t -> x = y)*)
                                   (lam  (*y'  : nat*)
                                      (lam (*eqb s x y' = t*)
                                         triv (*s x  = y  : nat*)
                                      )
                  )
               ))).
     (*          
  tr
    [:: hyp_tm
          (equal booltp
             (if_z (var 0)) btrue),
        hyp_tm nattp
      & G]
    (deq nzero
       (var (1 + 0)%coq_nat) nattp) *)

      Lemma bool_contra G J : tr G (deq bfalse btrue booltp) ->
                          tr G J.
    Admitted.

      Lemma equal_nzero_help G n:
        tr G (oof n nattp) -> tr G (oof (lam triv)
                                       (arrow (equal booltp (if_z n) btrue)
                                              (equal nattp nzero n)
                                       )
                                  ).
        intros. 
        replace 
    (oof (lam triv)
       (arrow
          (equal booltp 
             (if_z n) btrue)
          (equal nattp nzero n)))
 with
            (substj (dot n id) 
    (oof (lam triv)
       (arrow
          (equal booltp 
             (if_z (var 0)) btrue)
          (equal nattp nzero (var 0))))) .
        2:{ simpl. simpsub_big. auto. } 
        eapply (tr_generalize _ nattp). assumption.
        apply tr_arrow_intro; auto. { apply tr_equal_formation; auto.
                                      weaken tr_booltp_formation.
                                      apply if_z_typed. var_solv'. constructor. }
                                    { apply tr_equal_formation; auto. var_solv'. }
                                    simpsub_big.
        rewrite make_app1. eapply w_elim_hyp.
        weaken tr_booltp_formation. weaken nat_U01.
        change triv with (@subst obj (under 1 (dot (ppi2 (var 0)) (dot (ppi1 (var 0)) sh1))) triv). apply tr_sigma_eta_hyp. simpsub_big.
        simpl. simpsub_big. simpl.
        rewrite make_app2.
      match goal with |- tr ?G (deq triv triv ?T) =>
                      suffices: (tr G (oof (bite (var 2) triv triv) T)) end.
      { intros Hannoying. constructor. eapply deq_intro. apply Hannoying. }
      rewrite make_app2.
        change triv with 
            (@subst obj (under 2 sh1) triv).
        apply tr_booltp_eta_hyp; simpl; simpsub_big; simpl.
        { (*true*)
          rewrite make_app1.
          eapply tr_compute_hyp.
        {
          constructor. apply equiv_arrow. apply reduce_equiv.
          apply reduce_bite_beta1. apply reduce_id.
          apply equiv_refl.
        }
        constructor. apply tr_wt_intro. constructor.
        simpsub_big.
        eapply tr_compute. { apply equiv_arrow. apply reduce_equiv.
          apply reduce_bite_beta1. apply reduce_id.
          apply equiv_refl.
 } apply equiv_refl. apply equiv_refl.
        apply (tr_transitivity _#2 (lam (app (subst sh1 (var 1)) (var 0)))).
        { apply tr_arrow_intro; auto. weaken tr_voidtp_formation.
          eapply (tr_voidtp_elim  _ (var 0) (var 0)).
          change voidtp with (@subst obj (sh 1) voidtp). var_solv0.
        }
        { apply tr_symmetry. apply tr_arrow_eta.
          change (arrow voidtp nattp) with (@subst obj (sh 2) (arrow voidtp nattp)).
          var_solv0.
        }
        weaken nat_U01. }
        {(*false*)
          eapply (tr_compute_hyp _ [::]).
        {
          constructor. apply equiv_equal. apply equiv_refl. apply reduce_equiv.
          apply reduce_ppi1_beta. apply reduce_id.
          apply equiv_refl.
        }
        apply bool_contra. simpl. apply (deq_intro _#4 (var 0) (var 0)).
        change (equal booltp bfalse btrue) with (@subst obj sh1 (equal booltp bfalse btrue)).
        var_solv0. } 
       Qed. 


      Lemma equal_nzero G n:
        tr G (oof n nattp) ->
        tr G (deq (if_z n) btrue booltp) ->
        tr G (deq nzero n nattp).
        intros.
        apply (deq_intro _#4 (app (lam triv) triv) (app (lam triv) triv)).
        apply (tr_arrow_elim _ (equal booltp (if_z n) btrue)).
        apply tr_equal_formation; auto. weaken tr_booltp_formation.
        apply if_z_typed. assumption. constructor.
        apply tr_equal_formation; auto. apply equal_nzero_help. assumption.
        constructor. assumption. Qed.

  Lemma equal_succ G preds: tr G (oof preds (arrow unittp nattp)) ->
                        tr G (deq (nsucc (app preds triv )) (ppair bfalse preds) nattp).
    intros. unfold nsucc. simpsub. apply tr_wt_intro. constructor.
    simpsub_big.
    eapply tr_compute. { apply equiv_arrow. apply reduce_equiv.
                         apply reduce_bite_beta2. apply reduce_id. apply equiv_refl. } apply equiv_refl. apply equiv_refl.
    apply (tr_transitivity _ _ (lam (app (subst sh1 preds) (var 0)))).
    {
            apply tr_arrow_intro; auto.
            apply (tr_arrow_elim _ unittp); auto.
            match goal with |- tr ?G (deq ?M ?M ?T) =>
                                                      change T with
       (@shift obj 1
               (arrow unittp nattp)) end. rewrite subst_sh_shift. apply tr_weakening_append1.
            assumption.
          apply tr_symmetry. apply tr_unittp_eta.
          change unittp with (@subst obj (sh 1) unittp). var_solv0.
    }
    {
      apply tr_symmetry. apply tr_arrow_eta. assumption.
    }
    weaken nat_U01. Qed.

  Lemma eqb_sound G : tr G (oof eqb_sound_fn (pi nattp (pi nattp (arrow (equal booltp (app (eq_b (var 1)) (var 0))
                                                                               btrue
                                                                        )
                                                                        (equal nattp (var 1) (var 0))

                           )))).
    unfold eqb_sound_fn.
    assert (forall G' x, tr G' (oof x nattp) ->
                    tr G' (oof (pi nattp (arrow (equal booltp (app (eq_b (subst sh1 x)) (var 0))
                                                                               btrue
                                                                        )
                                                                        (equal nattp (subst sh1 x) (var 0))


                               ))
                               U0)
           ) as Hp.
    {
      intros. 
      apply tr_pi_formation_univ; auto.
      apply tr_arrow_formation_univ; auto.
      apply tr_equal_formation_univ; auto.
      simpsub_big. apply tr_booltp_formation.
      apply eqapp_typed; try var_solv'.  change nattp with (@subst obj sh1 nattp).
      rewrite ! subst_sh_shift. apply tr_weakening_append1. assumption.
      constructor.
      apply tr_equal_formation_univ; auto; try var_solv'.
      change nattp with (@subst obj sh1 nattp).
      rewrite ! subst_sh_shift. apply tr_weakening_append1. assumption.
    }
    eapply nat_ind_lamapp; simpsub_big; try reflexivity.
    { (*type p*)
      apply tr_arrow_intro; auto. simpsub_big.
      change (var 1) with (@subst obj sh1 (var 0)). apply Hp; var_solv'. }
    { (*type BC*)
       apply tr_pi_intro; auto. 
       apply tr_arrow_intro; auto. 
      apply tr_equal_formation; auto.
      weaken tr_booltp_formation.
      apply eqapp_typed; auto; try var_solv'. constructor.
      apply tr_equal_formation; auto; try var_solv'.
      eapply (tr_compute_hyp _ [::]). constructor. apply equiv_equal. apply equiv_refl.
      apply eq_b0. apply equiv_refl. simpl. simpsub_big.
      constructor. apply equal_nzero.
      var_solv'.
      apply (deq_intro _#4 (var 0) (var 0)).  
      match goal with |- tr ?G (deq ?M ?M ?T) => replace T with
          (subst sh1
       (equal booltp
              (if_z (var 0)) btrue)) end.
      2:{
        simpl. simpsub_big. auto.
      }
      var_solv0.
    }
    { (*type IS*)
       apply tr_pi_intro; auto. 
       apply tr_arrow_intro; auto.
       change (var 1) with (@subst obj sh1 (var 0)). weaken Hp.
       var_solv'.
       simpl. change (nsucc (var 1)) with (@subst obj sh1 (nsucc (var 0))).
       weaken Hp. apply nsucc_type. var_solv'.
       simpsub_big. apply tr_pi_intro; auto.
       apply tr_arrow_intro; auto.
      { apply tr_equal_formation; auto.
      weaken tr_booltp_formation.
      apply eqapp_typed; auto; try apply nsucc_type; try var_solv'. constructor. }
      { apply tr_equal_formation; auto; try apply nsucc_type; try var_solv'. }
      simpsub_big. eapply (tr_compute_hyp _ [::]).
      { constructor. apply equiv_equal. apply equiv_refl. apply eq_b_succ.
        apply equiv_refl. }
      (*split y into pair*)
      simpl. rewrite make_app1. apply w_elim_hyp. weaken tr_booltp_formation.
      weaken nat_U01.
      change triv with (@subst obj (under 1 (dot (ppi2 (var 0))
                                                 (dot (ppi1 (var 0)) sh1))) triv).
      apply tr_sigma_eta_hyp.
      simpsub_big. simpl. simpsub_big.
      eapply (tr_compute_hyp _ [::]).
      { constructor. apply equiv_equal. apply equiv_refl.
        apply equiv_bite. apply reduce_equiv.
        apply reduce_ppi1_beta. apply reduce_id. apply equiv_refl.
        apply equiv_app. apply equiv_refl. apply equiv_app.
        apply reduce_equiv. apply reduce_ppi2_beta. apply reduce_id.
        apply equiv_refl. apply equiv_refl.
      }
      simpl. rewrite make_app2.
      match goal with |- tr ?G (deq triv triv ?T) =>
                      suffices: (tr G (oof (bite (var 2) triv triv) T)) end.
      { intros Hannoying. constructor. eapply deq_intro. apply Hannoying. }
      change triv with (@subst obj (under 2 sh1) triv).
      apply tr_booltp_eta_hyp; simpl; simpsub_big.
      { (*y' = 0*)
        eapply (tr_compute_hyp _ [::]). { constructor. apply equiv_equal.
        apply equiv_refl. apply reduce_equiv. apply reduce_bite_beta1.
        apply reduce_id. apply equiv_refl. }
        apply bool_contra. simpl. apply (deq_intro _#4 (var 0) (var 0)).
        change (equal booltp bfalse btrue) with
            (@subst obj (sh 1) (equal booltp bfalse btrue)). var_solv0. }
      { (*y' = s y''*)
       simpl.  eapply (tr_compute_hyp _ [::]).
          { constructor. apply equiv_equal.
        apply equiv_refl. apply reduce_equiv. apply reduce_bite_beta2.
        apply reduce_id. apply equiv_refl. }
          simpl. rewrite make_app1. eapply tr_compute_hyp.
          { constructor. apply equiv_arrow. apply reduce_equiv.
       apply reduce_bite_beta2.
        apply reduce_id. apply equiv_refl. }
          simpl.
          constructor.
          eapply (tr_transitivity _#2 (nsucc (app (var 1) triv))).
          { (*succ x = succ (y' * *)
            apply nsucc_type.
            apply (deq_intro _#4 (app (app (var 2) (app (var 1) triv))
                                      (var 0))
                             (app (app (var 2) (app (var 1) triv))
                                      (var 0))
                  ).
            apply (tr_arrow_elim _
(equal booltp (app (eq_b (var 3)) (app (var 1) triv))
       btrue)).
      { apply tr_equal_formation; auto.
      weaken tr_booltp_formation.
      apply eqapp_typed; auto; try apply nsucc_type; try var_solv'.
      apply (tr_arrow_elim _ unittp); auto.
      change 
          (arrow unittp nattp) with (@subst obj (sh 2)
(arrow unittp nattp)
                                    ). var_solv'. constructor. constructor. }
      {
        apply tr_equal_formation; auto; try var_solv'.
        apply (tr_arrow_elim _ unittp); auto.
      change 
          (arrow unittp nattp) with (@subst obj (sh 2)
(arrow unittp nattp)
                                    ). var_solv'. constructor. 
      }
      match goal with |- tr ?G (deq ?M ?M ?T) => change T with
          (subst1 (app (var 1) triv)
       (arrow
          (equal booltp
             (app (eq_b (var 4))
                (var 0)) btrue)
          (equal nattp (var 4) (var 0)))) end.
      apply (tr_pi_elim _ nattp).
      match goal with |- tr ?G (deq ?M ?M ?T) => change T with
      ( subst (sh 3) (pi nattp
          (arrow
             (equal booltp
                (app (eq_b (var 1)) (var 0)) btrue)
             (equal nattp (var 1) (var 0))))) end. var_solv'.
        apply (tr_arrow_elim _ unittp); auto.
      change 
          (arrow unittp nattp) with (@subst obj (sh 2)
(arrow unittp nattp)
                                    ). var_solv'. constructor.
      match goal with |- tr ?G (deq ?M ?M ?T) => change T with
          (subst (sh 1)
       (equal booltp
          (app (eq_b (var 2)) (app (var 0) triv))
          btrue)) end. var_solv'. }
          {  apply equal_succ.
      change 
          (arrow unittp nattp) with (@subst obj (sh 2)
(arrow unittp nattp)
                                    ). var_solv'.  } } } 
Qed.

Lemma eqb_P G n m : tr G (oof n nattp) ->
                    tr G (oof m nattp) ->
  tr G (deq (app (eq_b n) m) btrue booltp) ->
                    tr G (deq n m nattp).
  intros.
  match goal with |- tr G ?J => replace J with (substj (dot triv id)
                                                    (deq (subst (sh 1) n)
                                                         (subst (sh 1) m)
                                                    nattp)
                                             ) end.
  2:{
    unfold substj. simpsub. auto.
  }
  eapply tr_generalize. apply tr_equal_intro in H1. apply H1.
  remember (subst (sh 1) n) as n'.
  remember (subst (sh 1) m) as m'.
  suffices: (tr (hyp_tm (equal booltp (app (eq_b n) m) btrue) :: G)
                (deq triv (app (app (app eqb_sound_fn n') m') (var 0))
                       (equal nattp n' m')
            )).
  move/ tr_eq_reflexivity => Hdeq.
  constructor. assumption.
  apply tr_symmetry. apply tr_equal_eta.
  assert (tr
    (hyp_tm (equal booltp (app (eq_b n) m) btrue)
     :: G) (deq n' n' nattp)) as Hn. 
    subst; change nattp with (@subst obj (sh 1) nattp);
      rewrite ! subst_sh_shift; apply tr_weakening_append1; assumption.
  assert (tr
    (hyp_tm (equal booltp (app (eq_b n) m) btrue)
     :: G) (deq m' m' nattp)) as Hm. 
  subst; change nattp with (@subst obj (sh 1) nattp);
      rewrite ! subst_sh_shift; apply tr_weakening_append1; assumption.
 (* replace (equal nattp n' m') with
      (subst1 (var 0) (equal nattp (subst (sh 1) n') (subst (sh 1) m'))). *)
  apply (tr_arrow_elim _ (equal booltp (app (eq_b n') m') btrue)
        ).
  - apply tr_equal_formation. weaken tr_booltp_formation.
    apply eqapp_typed; assumption.
    constructor. apply tr_equal_formation; auto.
    - match goal with |- tr ?G (deq ?M ?M ?T) => replace T with  
          (subst1 m' 
       (arrow
          (equal booltp (app (eq_b (subst (sh 1) n')) (var 0)) btrue)
          (equal nattp (subst (sh 1) n') (var 0)))) end.
      2:{
        unfold subst1. simpsub_big.  auto.
      }
      apply (tr_pi_elim _ nattp).
      match goal with |- tr ?G (deq ?M ?M ?T) => replace T with
       (subst1 n' (pi nattp
          (arrow
             (equal booltp
                (app
                   (eq_b (var 1))
                   (var 0)) btrue)
             (equal nattp  (var 1)
                (var 0))))) end.
      apply (tr_pi_elim _ nattp); try assumption. apply eqb_sound.
      simpsub_big. auto.
      assumption.
      match goal with |- tr ?G (deq ?M ?M ?T) => replace T with
      (subst (sh 1) (equal booltp (app (eq_b n) m) btrue)) end. var_solv0.
      subst. simpsub_big. auto.
Qed.

(*write out subseq refl and subseq trans on paper*)
