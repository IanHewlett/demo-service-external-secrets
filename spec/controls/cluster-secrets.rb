require 'json'

control "cluster-secrets" do
  title "cluster-secrets"
  tag "spec"

  app_name = "external-secrets-cluster-secrets"
  namespace = "kube-system"

  describe 'cluster-secret-store' do
    let(:ready_condition) { JSON.parse(`kubectl get clustersecretstore vault-admin -o jsonpath="{.status.conditions[?(@.type=='Ready')]}"`) }

    it 'is in a ready state' do
      expect(ready_condition.dig('status')).to eq("True")
    end
  end

  describe 'registry-credential' do
    let(:resource) { JSON.parse(`kubectl get secret registry-credential -n kube-system -o json`) }

    it 'registry-credential secret successfully generated' do
      expect(resource.dig('type')).to eq('kubernetes.io/dockerconfigjson')
      expect(resource.dig('data', '.dockerconfigjson')).not_to be_empty
    end
  end
end
