# atomes meson project file
# depending on meson version custom options can be read in:
# - 'meson_options.txt' (meson < 1.1.0)
# - 'meson.options'     (meson >= 1.1.0)

project ('atomes', 'c', 'fortran', 
        default_options : ['gtk=3', 'openmp=true'], 
        license : 'AGPL-3.0-or-later', 
        version : '1.1.15')

xml = dependency ('libxml-2.0')
pangoft = dependency ('pangoft2')
epoxy = dependency ('epoxy')
avutil = dependency ('libavutil')
avcodec = dependency ('libavcodec')
avformat = dependency ('libavformat')
swscale = dependency ('libswscale')
ffmpeg = [avutil, avcodec, avformat, swscale]
all_deps = [xml, pangoft, epoxy, ffmpeg]
all_test = [epoxy]

system = host_machine.system()
if system != 'windows'
  glu = dependency ('glu')
  all_deps = [all_deps, glu]
  all_test = [all_test, glu]
endif

if system == 'darwin'
  add_project_arguments ('-DOSX', language : 'c')
  gtk = dependency ('gtk4')
  add_project_arguments ('-DGTK4', language : 'c')
else
  gtk_version = get_option('gtk')
  if gtk_version == 3
    gtk = dependency ('gtk+-3.0')
    add_project_arguments ('-DGTK3', language : 'c')
    add_project_arguments ('-DMENU_ICONS', language : 'c')
  else 
    gtk = dependency ('gtk4')
    add_project_arguments ('-DGTK4', language : 'c')
  endif
  if system == 'linux'
    add_project_arguments ('-DLINUX', language : 'c')
    au = find_program ('appstream-util', required : true)
    dfi = find_program ('desktop-file-install', required : true)
    guic = find_program ('gtk-update-icon-cache', required : true)
    udd = find_program ('update-desktop-database', required : true)
    umd = find_program ('update-mime-database', required : true)
  elif system == 'windows'
    res = find_program ('windres', required : false)
    add_project_arguments ('-DWINDOWS', language : 'c')
  endif
endif
all_deps = [all_deps, gtk]
all_test = [all_test, gtk]

use_openmp = get_option('openmp')
if use_openmp
  omp = dependency('openmp', required : false)
  if omp.found ()
    all_deps = [all_deps, omp]
    add_project_arguments ('-DOPENMP', language : 'c')
    add_project_arguments ('-DOPENMP', language : 'fortran')
  else
    message ('OpenMP not found: turning OpenMP off')
  endif
endif

prog_name = meson.project_name()
prog_version = meson.project_version()
version_array = prog_version.split('.')
prog_major = version_array[0]
prog_minor = version_array[1]
prog_patch = version_array[2]
prog_string = ' '.join(prog_name, prog_version)
conf_data = configuration_data ()
conf_data.set ('ATOMES_MAJOR_VERSION', prog_major)
conf_data.set ('ATOMES_MINOR_VERSION', prog_minor)
conf_data.set ('ATOMES_PATCH_VERSION', prog_patch)
conf_data.set ('PACKAGE', prog_name)
conf_data.set ('VERSION', prog_version)
conf_data.set ('PACKAGE_VERSION', prog_version)
conf_data.set ('PACKAGE_NAME', prog_name)
conf_data.set ('PACKAGE_STRING', prog_string)
conf_data.set ('PACKAGE_URL', 'https://atomes.ipcms.fr')
conf_data.set ('PACKAGE_BUGREPORT', 'atomes@ipcms.unistra.fr')

configure_file (input : 'src/config.h.in', output : 'config.h', configuration : conf_data)
if system == 'windows' 
  if res.found()
    configure_file (input : 'misc/win/atomes.rc.in', output : 'atomes.rc', configuration : conf_data)
    configure_file (input : 'misc/win/startup.rc.in', output : 'startup.rc', configuration : conf_data)
    src_rc = [meson.current_build_dir() / 'atomes.rc']
    test_rc = [meson.current_build_dir() / 'startup.rc']
  endif
elif system == 'darwin'
  configure_file (input : 'misc/macos/Info.plist.in', output : 'Info.plist', configuration : conf_data)
  src_info = [meson.current_build_dir() / 'Info.plist']
endif

build_type = get_option('buildtype')
message ('Buildtype: ', build_type)
if build_type == 'release'
 compiler_args = ['-O3', '-g']
 flags = '-O3 -g'
elif build_type == 'debug'
 compiler_args = ['-O0', '-g3', '-fvar-tracking', '-fbounds-check', '-fstack-protector-all']
 flags = '-O0 -g3 -fvar-tracking -fbounds-check -fstack-protector-all'
else
 compiler_args = [ '-O2', '-g']
 flags = '-O2 -g'
endif
if system == 'darwin'
  compiler_args = [compiler_args, '-Wl,@loader_path/../Resources/lib']
endif

flag_data = configuration_data ()
fc_compiler = meson.get_compiler('fortran')
fc = ' '.join(fc_compiler.get_id(), fc_compiler.version())
flag_data.set ('FC', fc)
flag_data.set ('FCFLAGS', flags)
cc_compiler = meson.get_compiler('c')
cc = ' '.join(cc_compiler.get_id(), cc_compiler.version())
flag_data.set ('CC', cc)
flag_data.set ('CFLAGS', flags)

configure_file (input : 'src/version.h.in', output : 'version.h', configuration : flag_data)

add_project_arguments ('-DGTKGLAREA', language : 'c')
add_project_arguments ('-DHAVE_CONFIG_H', language : 'c')
add_project_arguments ('-DHAVE_CONFIG_H', language : 'fortran')

if system == 'darwin'
  res_dir = 'Contents/Resources'
  data_dir = res_dir / 'share'
  exec_dir = res_dir / get_option ('libexecdir')
else
  data_dir = get_option ('datadir')
  exec_dir = get_option ('libexecdir')
endif

if system != 'windows'
  if system == 'linux'
    data_prefix = get_option ('prefix') / data_dir
    package_prefix =  data_prefix / 'atomes'
    package_libexec = exec_dir
  else
    package_prefix = '..' / 'Resources' / 'share' / 'atomes'
    package_libexec = '..' / 'Resources' / get_option ('libexecdir')
  endif
  d_package_prefix = ''.join ('-DPACKAGE_PREFIX="', package_prefix, '"')
  add_project_arguments (d_package_prefix, language : 'c')
  d_package_libexec = ''.join ('-DPACKAGE_LIBEXEC="', package_libexec, '"')
  add_project_arguments (d_package_libexec, language : 'c')
endif

all_inc = ['.', 'src', 'src/gui', 
	'src/calc', 'src/calc/dl_poly', 'src/calc/lammps', 'src/calc/cpmd', 'src/calc/cp2k', 'src/calc/force_fields',
        'src/curve', 'src/project', 'src/project/readers', 'src/workspace',
        'src/opengl', 'src/opengl/win', 'src/opengl/edit', 'src/opengl/draw']
inc_dir = include_directories(all_inc)

src_top = ['src/global.c']

src_gui = ['src/gui/gtk-misc.c', 
	'src/gui/work_menu.c', 
	'src/gui/edit_menu.c', 
	'src/gui/calc_menu.c', 
	'src/gui/tools.c', 
	'src/gui/gui.c', 
	'src/gui/initc.c', 
	'src/gui/callbacks.c', 
	'src/gui/interface.c', 
	'src/gui/bdcall.c', 
	'src/gui/grcall.c', 
	'src/gui/sqcall.c', 
	'src/gui/ringscall.c', 
	'src/gui/chainscall.c', 
	'src/gui/msdcall.c', 
	'src/gui/spcall.c', 
	'src/gui/main.c']

src_dlpoly = ['src/calc/dl_poly/dlp_active.c', 
	'src/calc/dl_poly/dlp_control.c', 
	'src/calc/dl_poly/dlp_init.c', 
	'src/calc/dl_poly/dlp_active.c', 
	'src/calc/dl_poly/dlp_copy.c', 
	'src/calc/dl_poly/dlp_comp.c', 
	'src/calc/dl_poly/dlp_viz.c', 
	'src/calc/dl_poly/dlp_mol.c', 
	'src/calc/dl_poly/dlp_atom.c', 
	'src/calc/dl_poly/dlp_ff_match.c', 
	'src/calc/dl_poly/dlp_edit.c', 
	'src/calc/dl_poly/dlp_print.c', 
	'src/calc/dl_poly/dlp_field.c' ]

src_lammps = ['src/calc/lammps/la_print.c']

src_cpmd = ['src/calc/cpmd/cpmd_print.c', 
	'src/calc/cpmd/cpmd_nose.c', 
	'src/calc/cpmd/cpmd_restart.c', 
	'src/calc/cpmd/cpmd_atoms.c',
	'src/calc/cpmd/cpmd_init.c']

src_cp2k = ['src/calc/cp2k/cp2k_print.c', 
	'src/calc/cp2k/cp2k_molopt-basis.c', 
	'src/calc/cp2k/cp2k_gth-basis.c', 
	'src/calc/cp2k/cp2k_basis.c', 
	'src/calc/cp2k/cp2k_pot.c', 
	'src/calc/cp2k/cp2k_files.c', 
	'src/calc/cp2k/cp2k_mol.c', 
	'src/calc/cp2k/cp2k_init.c']

src_fields = ['src/calc/force_fields/force_fields.c']

src_calc = ['src/calc/calc.c', src_dlpoly, src_lammps, src_cpmd, src_cp2k, src_fields]

src_curve = ['src/curve/tab-1.c', 
	'src/curve/tab-2.c', 
	'src/curve/tab-3.c', 
	'src/curve/tab-4.c', 
	'src/curve/cedit.c', 
	'src/curve/datab.c', 
	'src/curve/cwidget.c', 
	'src/curve/glyph.c', 
	'src/curve/labels.c', 
	'src/curve/title.c', 
	'src/curve/legend.c', 
	'src/curve/xaxis.c', 
	'src/curve/yaxis.c', 
	'src/curve/frame.c', 
	'src/curve/draw.c', 
	'src/curve/show.c', 
	'src/curve/w_data.c', 
	'src/curve/w_img.c', 
	'src/curve/m_curve.c', 
	'src/curve/w_curve.c', 
	'src/curve/curve.c']

src_readers = ['src/project/readers/read_isaacs.c', 
	'src/project/readers/read_cif.c', 
	'src/project/readers/read_coord.c', 
	'src/project/readers/read_xyz.c', 
	'src/project/readers/read_c3d.c', 
	'src/project/readers/read_trj.c', 
	'src/project/readers/read_vas.c', 
	'src/project/readers/read_pdb.c', 
	'src/project/readers/read_hist.c', 
	'src/project/readers/read_npt.c']

src_proj = ['src/project/update_p.c', 
	'src/project/init_p.c', 
	'src/project/debugio.c', 
	'src/project/read_field.c', 
	'src/project/read_qm.c', 
	'src/project/read_opengl.c', 
	'src/project/read_curve.c', 
	'src/project/read_mol.c', 
	'src/project/read_bond.c', 
	'src/project/open_p.c', 
	'src/project/close_p.c', 
	'src/project/save_field.c', 
	'src/project/save_qm.c', 
	'src/project/save_opengl.c', 
	'src/project/save_curve.c', 
	'src/project/save_mol.c', 
	'src/project/save_bond.c', 
	'src/project/save_p.c', 
	'src/project/project.c',
        src_readers]

src_work = ['src/workspace/modelinfo.c', 
	'src/workspace/workinfo.c', 
        'src/workspace/workspace.c']

src_wingl = ['src/opengl/win/color_box.c', 
	'src/opengl/win/m_style.c', 
	'src/opengl/win/m_map.c', 
	'src/opengl/win/m_render.c', 
	'src/opengl/win/m_quality.c', 
	'src/opengl/win/m_atoms.c', 
	'src/opengl/win/m_bonds.c', 
	'src/opengl/win/m_clones.c', 
	'src/opengl/win/m_box.c', 
	'src/opengl/win/m_coord.c', 
	'src/opengl/win/m_poly.c', 
	'src/opengl/win/m_tools.c', 
	'src/opengl/win/m_edit.c', 
	'src/opengl/win/m_rep.c', 
	'src/opengl/win/m_proj.c', 
	'src/opengl/win/m_back.c', 
	'src/opengl/win/m_axis.c', 
	'src/opengl/win/m_anim.c', 
	'src/opengl/win/menu_bar.c', 
	'src/opengl/win/w_measures.c', 
	'src/opengl/win/w_volumes.c', 
	'src/opengl/win/w_colors.c', 
	'src/opengl/win/w_atoms.c', 
	'src/opengl/win/w_bonds.c', 
	'src/opengl/win/w_labels.c', 
	'src/opengl/win/w_search.c', 
	'src/opengl/win/w_periodic.c', 
	'src/opengl/win/w_library.c', 
	'src/opengl/win/w_cutoffs.c', 
	'src/opengl/win/w_rings.c', 
	'src/opengl/win/w_chains.c', 
	'src/opengl/win/w_coord.c', 
	'src/opengl/win/w_box.c', 
	'src/opengl/win/w_axis.c', 
	'src/opengl/win/w_advance.c', 
	'src/opengl/win/w_sequencer.c', 
	'src/opengl/win/w_spiner.c', 
	'src/opengl/win/w_encode.c', 
	'src/opengl/win/w_record.c', 
	'src/opengl/win/initcoord.c', 
	'src/opengl/win/initmol.c', 
	'src/opengl/win/initring.c', 
	'src/opengl/win/initchain.c', 
	'src/opengl/win/popup.c', 
	'src/opengl/win/glwindow.c']

src_edit = ['src/opengl/edit/cell_shift.c', 
	'src/opengl/edit/cell_extra.c', 
	'src/opengl/edit/cell_super.c', 
	'src/opengl/edit/cell_density.c', 
	'src/opengl/edit/cell_cut.c', 
	'src/opengl/edit/cell_pixel.c', 
	'src/opengl/edit/cell_edit.c', 
	'src/opengl/edit/atom_action.c', 
	'src/opengl/edit/atom_coord.c', 
	'src/opengl/edit/atom_geo.c', 
	'src/opengl/edit/atom_insert.c', 
	'src/opengl/edit/atom_move.c', 
	'src/opengl/edit/atom_object.c', 
	'src/opengl/edit/atom_remove.c', 
	'src/opengl/edit/atom_search.c', 
	'src/opengl/edit/atom_species.c', 
	'src/opengl/edit/atom_edit.c', 
	'src/opengl/edit/cbuild_action.c', 
	'src/opengl/edit/cbuild_sg.c', 
	'src/opengl/edit/cbuild_info.c', 
	'src/opengl/edit/cbuild_edit.c']

src_draw = ['src/opengl/draw/d_atoms.c', 
	'src/opengl/draw/d_bonds.c', 
	'src/opengl/draw/d_label.c', 
	'src/opengl/draw/d_selection.c', 
	'src/opengl/draw/d_poly.c', 
	'src/opengl/draw/d_rings.c', 
	'src/opengl/draw/d_box.c', 
	'src/opengl/draw/d_axis.c', 
	'src/opengl/draw/d_measures.c', 
	'src/opengl/draw/ogl_text.c', 
	'src/opengl/draw/movie.c', 
	'src/opengl/draw/image.c']

src_opengl = ['src/opengl/arcball.c', 
	'src/opengl/selection.c', 
	'src/opengl/ogl_utils.c', 
	'src/opengl/ogl_shaders.c', 
	'src/opengl/ogl_shading.c', 
	'src/opengl/ogl_draw.c', 
	'src/opengl/glview.c' , src_draw, src_wingl, src_edit]

src_c = [src_top, src_gui, src_calc, src_curve, src_proj, src_work, src_opengl]

src_f = ['src/fortran/allocbonds.F90', 
	'src/fortran/allochem.F90', 
	'src/fortran/allocmsd.F90', 
	'src/fortran/angles.F90', 
	'src/fortran/bonds.F90', 
	'src/fortran/c3d.F90', 
	'src/fortran/chains.F90', 
	'src/fortran/chains_ogl.F90', 
	'src/fortran/chemistry.F90', 
	'src/fortran/clean.F90', 
	'src/fortran/cqvf.F90', 
	'src/fortran/dmtx.F90', 
	'src/fortran/allocbonds.F90', 
	'src/fortran/allochem.F90', 
	'src/fortran/allocmsd.F90', 
	'src/fortran/angles.F90', 
	'src/fortran/bonds.F90', 
	'src/fortran/c3d.F90', 
	'src/fortran/chains.F90', 
	'src/fortran/chains_ogl.F90', 
	'src/fortran/chemistry.F90', 
	'src/fortran/clean.F90', 
	'src/fortran/cqvf.F90', 
	'src/fortran/dmtx.F90', 
	'src/fortran/dvtb.F90', 
	'src/fortran/escs.F90', 
	'src/fortran/fzbt.F90', 
	'src/fortran/gr.F90', 
	'src/fortran/grfft.F90', 
	'src/fortran/initchains.F90', 
	'src/fortran/initrings.F90', 
	'src/fortran/lattice.F90', 
	'src/fortran/mendeleiev.F90', 
	'src/fortran/molecules.F90', 
	'src/fortran/msd.F90', 
	'src/fortran/parameters.F90', 
	'src/fortran/pdb.F90', 
	'src/fortran/prepdata.F90', 
	'src/fortran/resrings.F90', 
	'src/fortran/rings-guttman.F90', 
	'src/fortran/rings-king.F90', 
	'src/fortran/rings_ogl.F90', 
	'src/fortran/rings-primitive.F90', 
	'src/fortran/sk.F90', 
	'src/fortran/spherical.F90', 
	'src/fortran/sq.F90', 
	'src/fortran/threads.F90', 
	'src/fortran/trj.F90', 
	'src/fortran/utils.F90', 
	'src/fortran/vas.F90', 
	'src/fortran/writedata.F90', 
	'src/fortran/xyz.F90', 
	'src/fortran/dvtb.F90',  
	'src/fortran/escs.F90',  
	'src/fortran/fzbt.F90',  
	'src/fortran/gr.F90',  
	'src/fortran/grfft.F90',  
	'src/fortran/initchains.F90', 
	'src/fortran/initrings.F90', 
	'src/fortran/lattice.F90', 
	'src/fortran/mendeleiev.F90', 
	'src/fortran/molecules.F90', 
	'src/fortran/msd.F90', 
	'src/fortran/parameters.F90', 
	'src/fortran/pdb.F90', 
	'src/fortran/prepdata.F90', 
	'src/fortran/resrings.F90', 
	'src/fortran/rings-guttman.F90', 
	'src/fortran/rings-king.F90', 
	'src/fortran/rings_ogl.F90', 
	'src/fortran/rings-primitive.F90', 
	'src/fortran/sk.F90', 
	'src/fortran/spherical.F90', 
	'src/fortran/sq.F90', 
	'src/fortran/threads.F90', 
	'src/fortran/trj.F90', 
	'src/fortran/utils.F90', 
	'src/fortran/vas.F90', 
	'src/fortran/writedata.F90', 
	'src/fortran/xyz.F90']

# atomes sources
src_all = [src_c, src_f]
# atomes OpenGL test utility
src_test = ['src/startup-testing/startup_testing.c']

if system == 'windows'
  windows = import('windows')
  src_win = windows.compile_resources (src_rc)
  src_all = [src_all, src_win]
  test_win = windows.compile_resources (test_rc)
  src_test = [src_test, test_win]
  executable ('atomes_startup_testing', sources : src_test, include_directories : inc_dir, dependencies: all_test, 
	c_args: compiler_args, fortran_args: compiler_args, install : true) 
else
  executable ('atomes_startup_testing', sources : src_test, include_directories : inc_dir, dependencies: all_deps, 
	c_args: compiler_args, fortran_args: compiler_args, install : true, install_dir : package_libexec) 
endif
if system == 'darwin'
  application = '-'.join(prog_name, 'bin')
else
  application = prog_name
endif
executable (application, sources : src_all, include_directories : inc_dir, dependencies: all_deps, 
	c_args: compiler_args, fortran_args: compiler_args, install : true)

# Manual page
install_man ('atomes.1')

data_dir = get_option ('datadir')

# Data
install_subdir ('data/pixmaps', install_dir: data_dir / 'atomes')
install_subdir ('data/library', install_dir : data_dir / 'atomes')

if system == 'windows'
# Doc
  install_data ('README.md', install_dir : data_dir / 'atomes')
  install_data ('AUTHORS', install_dir : data_dir / 'atomes')
  install_data ('ChangeLog', install_dir : data_dir / 'atomes')
else
  if system == 'linux'
# Metadata
  install_data ('metadata/icons/atomes.svg', install_dir : data_dir / 'pixmaps')
  install_data ('metadata/icons/atomes-workspace.svg', install_dir : data_dir / 'pixmaps')
  install_data ('metadata/icons/atomes-project.svg', install_dir : data_dir / 'pixmaps')
  install_data ('metadata/icons/atomes-coordinates.svg', install_dir : data_dir / 'pixmaps')
  install_data ('metadata/atomes-mime.xml', install_dir : data_dir / 'mime/packages')
  install_data ('metadata/fr.ipcms.atomes.appdata.xml', install_dir : data_dir / 'metainfo')
  install_data ('metadata/atomes.desktop', install_dir :  data_dir / 'applications')
  meson.add_install_script ('misc/linux/post_install.sh', data_prefix)
  elif system == 'darwin'
    install_data('misc/macos/atomes.icns', install_dir : res_dir)
    install_data('misc/macos/atomes-workspace.icns', install_dir : res_dir)
    install_data('misc/macos/atomes-project.icns', install_dir : res_dir)
    install_data('misc/macos/atomes-coordinates.icns', install_dir : res_dir)
    install_data('misc/macos/PkgInfo', install_dir : 'Contents')
    install_data(src_info, install_dir : 'Contents')
    install_data('misc/macos/atomes.sh', install_dir : 'Contents/MacOS', rename : 'atomes')
    meson.add_install_script ('misc/macos/install_lib.sh')
  endif
# Doc
  install_data ('README.md', install_dir : data_dir / 'doc/atomes')
  install_data ('AUTHORS', install_dir : data_dir / 'doc/atomes')
  install_data ('ChangeLog', install_dir : data_dir / 'doc/atomes')
# Bash completion
  install_data ('atomes-completion.sh', rename : 'atomes', install_dir : data_dir / 'bash-completion/completions')
endif
