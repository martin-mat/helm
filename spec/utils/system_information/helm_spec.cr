require "kubectl_client"
require "../../spec_helper"
require "colorize"
require "../../../src/utils/utils.cr"
require "../../../src/tasks/utils/system_information/helm.cr"

describe "Helm" do
  describe "global" do
    before_all do
      helm_local_cleanup
    end

    it "'helm_global_response()' should return the information about the helm installation", tags: ["helm-utils"]  do
      (SystemInfo::Helm.global_helm_installed?).should be_true
    end

    it "'helm_installations()' should return the information about the helm installation", tags: ["helm-utils"]  do
      (helm_installation(true)).should contain("helm found")
    end
  
    it "'Helm.helm_gives_k8s_warning?' should pass when k8s config = chmod 700", tags: ["helm-utils"]  do
      (Helm.helm_gives_k8s_warning?(true)).should be_false
    end
    
    it "'Helm.helm_repo_add' should work", tags: ["helm-utils"]  do
      stable_repo = Helm.helm_repo_add("stable", "https://cncf.gitlab.io/stable")
      Log.for("verbose").debug { "stable repo add: #{stable_repo}" }
      (stable_repo).should be_true
    end

  end

  describe "local" do
    before_all do
      install_local_helm
    end

    it "'helm_local_response()' should return the information about the helm installation", tags: ["helm-utils"]  do
      Helm::ShellCmd.run("ls -R tools/helm", "helm_dir_check", force_output: true)
      (helm_local_response(true)).should contain("\"v3.")
    end
    
    it "'helm_version()' should return the information about the helm version", tags: ["helm-utils"]  do
      Helm::ShellCmd.run("ls -R tools/helm", "helm_dir_check", force_output: true)
      (helm_version(helm_local_response)).should contain("v3.")
    end
    
    it "'Helm.helm_repo_add' should work", tags: ["helm-utils"]  do
      stable_repo = Helm.helm_repo_add("stable", "https://cncf.gitlab.io/stable")
      Log.for("verbose").debug { "stable repo add: #{stable_repo}" }
      (stable_repo).should be_true
    end
  end
end
