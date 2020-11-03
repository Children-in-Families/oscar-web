namespace :program_stream do
  desc 'Correct client birth provinces'
  task clone: :environment do
    PaperTrail.enabled = false

    org_short_name = 'isf'
    program_stream_id = 2
    new_program_name = 'Education - Chbar Ampov'

    Organization.switch_to org_short_name
    program_stream = ProgramStream.find(program_stream_id)

    new_program = program_stream.dup
    new_program.name = new_program_name
    new_program.completed = true

    ProgramStream.skip_callback(:create, :after, :build_permission)
    ProgramStream.skip_callback(:save, :before, :set_program_completed)
    ProgramStream.skip_callback(:save, :before, :destroy_tracking)

    new_program.save(validate: false)

    program_stream.program_stream_services.each do |pss|
      new_pss = pss.dup
      new_pss.program_stream = new_program
      new_pss.save
    end

    program_stream.program_stream_permissions.each do |psp|
      new_psp = psp.dup
      new_psp.program_stream = new_program
      new_psp.save
    end

    program_stream.domain_program_streams.each do |dps|
      new_dps = dps.dup
      new_dps.program_stream = new_program
      new_dps.save
    end

    program_stream.update_columns(name: 'Education - Steng Mean Chey')

    Client.where(slug: move_client_ids).each do |client|
      program_stream.client_enrollments.where(client_id: client.id).each do |client_enrollment|
        client_enrollment.program_stream = new_program
        client_enrollment.save(validate: false)
        client_enrollment.trackings.update_all(program_stream_id: new_program)
      end
    end
  end

  def move_client_ids
    %w(
      eymg-1158
      apw-1010
      pdg-1006
      fmq-1012
      uxo-783
      bif-1029
      los-923
      cne-763
      wkch-1082
      grw-795
      lrt-810
      rxq-1051
      lfo-929
      wjk-802
      wlv-885
      mty-938
      mju-896
      hiv-922
      kto-867
      ejg-964
      gqw-926
      nms-911
      ikm-936
      icu-934
      laj-806
      ulb-965
      kyv-811
      vzr-912
      exo-1002
      aqz-792
      clf-983
      jdfz-1139
      vby-853
      fae-767
      gcw-762
      paj-761
      trq-758
      mvt-773
      zjn-775
      rdm-779
      fow-787
      czy-788
      hyd-782
      xly-770
      val-801
      sbj-833
      ycs-790
      wju-798
      pem-903
      sqd-891
      itr-893
      meo-887
      fqn-899
      gwt-892
      njp-924
      fxu-910
      plfs-1124
      iapn-1130
      fgus-1129
      you-978
      pzb-982
      rft-984
      vol-994
      xrh-986
      wmy-989
      dhq-946
      dvt-985
      enr-988
      qis-955
      loc-973
      ptk-1005
      csh-1011
      xhf-1004
      jbq-996
      qmk-1047
      vds-1039
      phw-1033
      dji-1044
      yvo-1050
      bax-1040
      hgn-1045
      hoa-1031
      loh-1042
      lysk-1062
      odvw-1125
      dta-874
      hsfc-1064
      hsni-1066
      bseh-1127
      fqgk-1135
      vufe-1133
      feiv-1165
      ptzi-1134
      recj-1137
      etno-1167
      geuh-1140
      ldza-1159
      aml-768
      drj-766
      lco-769
      smf-777
      kcn-781
      cer-800
      qzn-823
      jzh-796
      giu-846
      izv-1015
      cwf-865
      yrz-976
      ena-886
      dqu-925
      knr-904
      uhq-908
      prm-916
      jxu-917
      pqe-919
      lgs-918
      mxz-940
      wuy-941
      ohs-987
      kiz-992
      ihz-1000
      bsz-1014
      fnv-1028
      drx-993
      zpg-826
      fgw-1035
      cmfs-1149
      yfw-898
      xcm-980
      xjt-789
      tpo-944
      dtm-945
      egf-968
      ouzp-1156
      xlus-1147
      mqkv-1151
      vrdi-1150
      rlgb-1152
      ovy-776
      nvc-797
      drf-682
      jfq-831
      npw-750
      voa-780
      laz-808
      mux-1023
      iwzy-1113
      hjg-755
      qwp-702
      shp-793
      yqo-794
      dbl-872
      ivnw-1132
      phr-737
      uthr-1148
      cyas-1153
      kti-733
      hwo-803
      xtk-744
      rwa-741
      dpv-748
      gwv-754
      dwo-756
      oxp-724
      jia-809
      fpe-752
      nik-813
      hds-727
      ioy-746
      mpvn-1057
      qxoh-1055
      yim-723
      qsz-728
      mxv-861
      pryv-1058
      daq-1008
      upl-685
      lmz-943
      ros-745
      nax-736
      ofc-804
      zrk-1009
      rwa-1007
      tmw-765
      pmd-855
      rhy-857
      epix-1121
      pwd-829
      wip-814
      qex-738
      bfs-732
      uoi-815
      zhl-942
      yko-743
      usy-739
      xrc-817
      dcb-827
      grb-837
      jae-838
      fya-821
      nct-683
      qgw-856
      fuq-1019
      nwp-871
      foj-858
      wjk-889
      nux-834
      mpd-879
      pza-825
      kat-698
      ycm-897
      cnr-1024
      cya-735
      jet-772
      dgt-774
      kqy-906
      vzy-1049
      lvr-1025
      alkm-1063
      irj-694
      plk-820
      eaj-894
      mph-927
      omp-684
      rob-816
      pfx-995
      ebz-830
      hdl-947
      ask-845
      vey-835
      pjno-1060
      yat-913
      fxd-1032
      vwa-880
      ikx-786
      yxk-881
      hfp-888
      lfp-928
      ufj-691
      nzy-822
      iho-843
      dnp-1030
      qpk-1017
      mjc-791
      xhk-688
      oew-997
      laj-778
      xkz-901
      dqg-902
      zda-828
      ukwh-1056
      per-836
      amg-686
      gkd-696
      cqms-1059
      dju-852
      mex-905
      urb-920
      cbqh-1122
      eyl-1022
      upl-841
      iwx-799
      unt-939
      fmhv-1117
      uzh-784
      dgf-914
      mdpx-1146
      hwp-1052
      rpd-884
      pba-764
      ornq-1120
      uks-981
      jpz-895
      zir-990
      pdo-883
      odk-785
      zni-876
      xwl-824
      equ-849
      hkw-1027
      obx-948
      yta-907
      wqr-771
      uzj-842
      zdu-747
      zqv-930
      hri-1048
      nwf-1021
      vrt-954
      ctzh-1119
      lkby-1136
      syuq-1157
      fls-1026
      ibl-890
      vmqy-1166
      kzyg-1154
      tqf-695
      ivp-700
      izeu-1173
      stzh-1174
      jwpv-1175
      irqs-1176
      iftm-1177
      huxr-1054
      xnqf-1178
      anpc-1179
      udzc-1180
      nlvj-1181
      fnud-1182
      yowz-1183
      jvbd-1184
      ezch-1185
      ducl-1186
      xjur-1187
      cvae-1188
      bovf-1189
      dqgf-1190
      esja-1191
      kaeq-1192
      lejt-1193
      skbl-1194
      kxzt-1195
      bqcv-1196
      ztud-1197
      hfdr-1155
      goyi-1198
      oegi-1199
      pbq-909
      pke-1013
      vabf-1200
      trq-751
      kre-729
      glo-832
      zba-847
      zdg-819
      jxu-818
      hqy-877
      mkx-839
      wfs-730
      doih-1201
      jpil-1202
      udmp-1203
      gcoy-1204
      gex-812
      zcmu-1061
      ljgh-1131
      gwr-850
      vdz-991
      pvj-1003
      xbr-882
      tsi-878
      hxa-840
      qous-1205
      nfam-1206
      klsp-1207
      oane-1208
      waj-873
      fym-1043
      huc-998
    )
  end
end
