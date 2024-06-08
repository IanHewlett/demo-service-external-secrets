require 'json'

control "cluster-role-bindings" do
  title "cluster-role-bindings"
  tag "spec"

  describe 'auth-delegator-cluster-role-binding' do
    it 'should have auth-delegator-cluster-role-binding' do
        clusterrole_bindings = JSON.parse(`kubectl get clusterrolebindings -o json`)['items']
        expect(clusterrole_bindings).to include(include({
          'metadata' => include({
            'name' => "vault-review-binding"
          }),
          'roleRef' => include({
            'name' => "system:auth-delegator"
          }),
          'subjects' => include(include({
            'kind' => 'Group',
            'name' => "system:serviceaccounts"
          }))
        }))
      end
  end
end
