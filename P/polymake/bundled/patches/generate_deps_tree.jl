using Pkg.Artifacts
using polymake_jll

function prepare_deps_tree()
   mutable_artifacts_toml = joinpath(dirname(pathof(polymake_jll)), "..", "MutableArtifacts.toml")
   polymake_tree = "polymake_tree"
   polymake_tree_hash = artifact_hash(polymake_tree, mutable_artifacts_toml)

   # create a directory tree for polymake with links to dependencies
   # looking similiar to the tree in the build environment
   # for compiling wrappers at run-time
   polymake_tree_hash = create_artifact() do art_dir
      mkpath(joinpath(art_dir,"deps"))
      for dep in [polymake_jll.FLINT_jll,
                  polymake_jll.GMP_jll,
                  polymake_jll.MPFR_jll,
                  polymake_jll.PPL_jll,
                  polymake_jll.Perl_jll,
                  polymake_jll.bliss_jll,
                  polymake_jll.boost_jll,
                  polymake_jll.cddlib_jll,
                  polymake_jll.lrslib_jll,
                  polymake_jll.normaliz_jll]
         symlink(dep.artifact_dir, joinpath(art_dir,"deps","$dep"))
      end
      for dir in readdir(polymake_jll.artifact_dir)
         symlink(joinpath(polymake_jll.artifact_dir,dir), joinpath(art_dir,dir))
      end
   end

   bind_artifact!(mutable_artifacts_toml,
      polymake_tree,
      polymake_tree_hash;
      force=true
   )

   # Point polymake to our custom tree
   return artifact_path(polymake_tree_hash)
end
