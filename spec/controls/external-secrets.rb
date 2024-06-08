require 'json'

control "external-secrets" do
  title "external-secrets"
  tag "spec"

  app_name = "external-secrets"
  namespace = "kube-system"
  chart_repo = "chart-external-secrets"
  chart_name = "external-secrets"
  # chart_version = env_vars['external_secrets']['chart_version']
  deployment_name = "external-secrets"
  replicas = 1
  node_group = input('management_node_group_name')
  toleration_value = input('management_node_group_role')

  # describe 'flux helmrepository' do
  #   let(:ready_condition) { JSON.parse(`kubectl get helmrepository #{chart_repo} -n #{namespace} -o jsonpath="{.status.conditions[?(@.type=='Ready')]}"`) }
  #
  #   it "is in a ready state" do
  #     expect(ready_condition.dig('status')).to eq("True")
  #   end
  # end

  describe 'flux helmrelease' do
    let(:ready_condition) { JSON.parse(`kubectl get helmrelease #{app_name} -n #{namespace} -o jsonpath="{.status.conditions[?(@.type=='Ready')]}"`) }

    it "is in a ready state" do
      expect(ready_condition.dig('status')).to eq("True")
    end
  end

  describe 'external-secrets installation' do
    before { `kubectl rollout status deployment #{deployment_name} -n #{namespace} --timeout=1m` }
    let(:resource) { JSON.parse(`kubectl get deployment #{deployment_name} -n #{namespace} -o json`) }

    it 'has 3 ready replicas' do
      expect(resource.dig('status', 'replicas')).to eq("#{replicas}".to_i)
      expect(resource.dig('status', 'readyReplicas')).to eq("#{replicas}".to_i)
    end

    describe 'pods' do
      pods = JSON.parse(`kubectl get pods -n #{namespace} -l "app.kubernetes.io/name=#{app_name}" -o json`)

      pods.dig('items').each do |pod|
        describe pod.dig('metadata', 'name') do

          it "should run on a #{toleration_value} node" do
            expect(pod).to run_on_node_group("#{node_group}")
          end
        end
      end

      it "should be running on different nodes" do
        expect(pods.dig('items').map { |x| x.dig('spec', 'nodeName') }).to be_unique
      end
    end
  end

  describe 'external-secrets-cert-controller installation' do
    before { `kubectl rollout status deployment external-secrets-cert-controller -n kube-system --timeout=1m` }
    let(:resource) { JSON.parse(`kubectl get deployment external-secrets-cert-controller -n kube-system -o json`) }

    it 'has 3 ready replicas' do
      expect(resource.dig('status', 'replicas')).to eq("#{replicas}".to_i)
      expect(resource.dig('status', 'readyReplicas')).to eq("#{replicas}".to_i)
    end

    describe 'pods' do
      pods = JSON.parse(`kubectl get pods -n #{namespace} -l "app.kubernetes.io/name=external-secrets-cert-controller" -o json`)

      pods.dig('items').each do |pod|
        describe pod.dig('metadata', 'name') do

          it "should run on a #{toleration_value} node" do
            expect(pod).to run_on_node_group("#{node_group}")
          end
        end
      end

      it "should be running on different nodes" do
        expect(pods.dig('items').map { |x| x.dig('spec', 'nodeName') }).to be_unique
      end
    end
  end

  describe 'external-secrets-webhook installation' do
    before { `kubectl rollout status deployment external-secrets-webhook -n kube-system --timeout=1m` }
    let(:resource) { JSON.parse(`kubectl get deployment external-secrets-webhook -n kube-system -o json`) }

    it 'has 3 ready replicas' do
      expect(resource.dig('status', 'replicas')).to eq("#{replicas}".to_i)
      expect(resource.dig('status', 'readyReplicas')).to eq("#{replicas}".to_i)
    end

    describe 'pods' do
      pods = JSON.parse(`kubectl get pods -n #{namespace} -l "app.kubernetes.io/name=external-secrets-webhook" -o json`)

      pods.dig('items').each do |pod|
        describe pod.dig('metadata', 'name') do

          it "should run on a #{toleration_value} node" do
            expect(pod).to run_on_node_group("#{node_group}")
          end
        end
      end

      it "should be running on different nodes" do
        expect(pods.dig('items').map { |x| x.dig('spec', 'nodeName') }).to be_unique
      end
    end
  end
end
