module Intrigue
  module Task
    class WsoTwoDefaultLogin < BaseTask
      include Intrigue::Task::Web
      include Intrigue::Task::BruteForceLoginHelper

      def self.metadata
        {
          name: 'vuln/bruteforce/wso2_login_vuln',
          pretty_name: 'Bruteforce - WSO2 Default Login Credentials',
          authors: [''],
          description: 'Bruteforce WSO2 Default Login Credentials',
          type: 'Vuln',
          passive: false,
          allowed_types: ['Uri'],
          example_entities: [
            { 'type' => 'Uri', 'details' => { 'name' => 'http://intrigue.io' } }
          ],
          allowed_options: [
            { name: 'threads', regex: 'integer', default: 10 }
          ],
          created_types: ['Uri']
        }
      end

      def run
        super
        require_enrichment

        fingerprint = _get_entity_detail('fingerprint')

        return false unless vendor?(fingerprint,
                                    'WSO2') && is_product?(finerprint, 'Carbon') && tag?(fingerprint, 'Login Panel')

        credentials = [
          {
            user: 'admin',
            password: 'admin'
          }
        ]

        task_information = {
          http_method: :get,
          uri: _get_entity_name,
          headers: {},
          data: nil,
          follow_redirects: true,
          timeout: 10,
          thread_count: _get_option('threads')
        }

        # brute with force.
        bruteforce_login_and_create_issue(task_information, method(:validator))

      end

      # custom validator, each default login task will have its own.
      # some tasks might require a more complex approach.
      def validator(response)
        !response.body_utf8.match(/Login failed\. Please recheck the user name and password and try again/i) && response.code.to_i.between?(
          199, 300
        )
      end
    end
  end
end
