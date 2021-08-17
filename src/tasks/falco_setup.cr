require "sam"
require "file_utils"
require "colorize"
require "totem"
require "./utils/utils.cr"

FALCO_OFFLINE_DIR = "#{TarClient::TAR_REPOSITORY_DIR}/falcosecurity_falco"

desc "Install Falco"
task "install_falco" do |_, args|
  helm = BinarySingleton.helm
  # todo create embedded file macro for falco_rule
  if args.named["offline"]?
      Log.info { "install falco offline mode" }
    helm_chart = Dir.entries(FALCO_OFFLINE_DIR).first
  # todo create embedded file macro for falco_rule
    Helm.install("falco --set ebpf.enabled=true -f ./embedded_files/falco_rule.yaml #{FALCO_OFFLINE_DIR}/#{helm_chart}")
    KubectlClient::Get.resource_wait_for_install("Daemonset", "falco") 

  else
    Helm.helm_repo_add("falcosecurity","https://falcosecurity.github.io/charts")
    # needs ebpf parameter for precompiled module 
    Helm.install("falco --set ebpf.enabled=true -f ./embedded_files/falco_rule.yaml falcosecurity/falco")
    KubectlClient::Get.resource_wait_for_install("Daemonset", "falco") 
  end
end

desc "Uninstall Falco"
task "uninstall_falco" do |_, args|
  Log.for("verbose").info { "uninstall_falco" } if check_verbose(args)
  current_dir = FileUtils.pwd
  helm = BinarySingleton.helm
  cmd = "#{helm} delete falco > /dev/null 2>&1"
  status = Process.run(
    cmd,
    shell: true,
    output: output = IO::Memory.new,
    error: stderr = IO::Memory.new
  )
end

