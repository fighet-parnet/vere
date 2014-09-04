/* j/6/cons.c
**
** This file is in the public domain.
*/
#include "all.h"


/* functions
*/
  u2_noun
  u2_cqf_cons(
                    u2_noun vur,
                    u2_noun sed)
  {
    u2_noun p_vur, p_sed;

    if ( u2_yes == u2_cr_p(vur, 1, &p_vur) &&
         u2_yes == u2_cr_p(sed, 1, &p_sed) ) {
      return u2nt(1,
                          u2k(p_vur),
                          u2k(p_sed));
    }
    else if ( u2_yes == u2_cr_p(vur, 0, &p_vur) &&
              u2_yes == u2_cr_p(sed, 0, &p_sed) &&
              !(u2_yes == u2_cr_sing(1, p_vur)) &&
              !(u2_yes == u2_cr_sing(p_vur, p_sed)) &&
              (0 == u2_cr_nord(p_vur, p_sed)) )
    {
      u2_atom fub = u2_cqa_div(p_vur, 2);
      u2_atom nof = u2_cqa_div(p_sed, 2);

      if ( u2_yes == u2_cr_sing(fub, nof) ) {
        u2z(nof);

        return u2nc(0, fub);
      }
      else {
        u2z(fub);
        u2z(nof);
      }
    }
    return u2nc(u2k(vur), u2k(sed));
  }
  u2_noun
  u2_cwf_cons(
                   u2_noun cor)
  {
    u2_noun vur, sed;

    if ( u2_no == u2_cr_mean(cor, u2_cv_sam_2, &vur, u2_cv_sam_3, &sed, 0) ) {
      return u2_cm_bail(c3__fail);
    } else {
      return u2_cqf_cons(vur, sed);
    }
  }
