"""
Sphinx extension to display GitHub contributors.
"""

import os
import json
import requests
from docutils import nodes
from docutils.parsers.rst import Directive, directives


class GithubContributorsDirective(Directive):
    """
    Directive to display GitHub contributors.
    
    Usage:
    .. github-contributors:: owner/repo
       :max: 10
       :columns: 4
    """
    
    required_arguments = 1
    optional_arguments = 0
    option_spec = {
        'max': directives.positive_int,
        'columns': directives.positive_int,
        'exclude': directives.unchanged,
    }
    has_content = False
    
    def run(self):
        # Parse arguments
        repo_path = self.arguments[0]
        max_contributors = self.options.get('max', 100)
        columns = self.options.get('columns', 4)
        exclude_logins = self.options.get('exclude', '').split(',')
        exclude_logins = [login.strip() for login in exclude_logins if login.strip()]
        
        try:
            # Use GitHub API to get contributors
            api_url = f"https://api.github.com/repos/{repo_path}/contributors?per_page={max_contributors}"
            
            # Check for GitHub token in environment variables
            github_token = os.environ.get('GITHUB_TOKEN', '')
            headers = {}
            if github_token:
                headers['Authorization'] = f'token {github_token}'
                
            response = requests.get(api_url, headers=headers)
            response.raise_for_status()
            contributors = response.json()
            
            # Filter excluded contributors
            contributors = [c for c in contributors if c['login'] not in exclude_logins]
            
            # Create a container div for the contributors grid
            container = nodes.container(classes=['contributors-grid'])
            container.append(nodes.raw('', 
                f'<style>.contributors-grid {{ display: grid; grid-template-columns: repeat({columns}, 1fr); gap: 20px; }}</style>', 
                format='html'))
            
            # Add each contributor
            for contributor in contributors[:max_contributors]:
                login = contributor['login']
                avatar_url = contributor['avatar_url']
                profile_url = contributor['html_url']
                contributions = contributor['contributions']
                
                # Create a container for this contributor
                contributor_div = nodes.container(classes=['contributor'])
                contributor_div.append(nodes.raw('', 
                    f'''
                    <div style="text-align: center; margin-bottom: 10px;">
                        <a href="{profile_url}" target="_blank" style="text-decoration: none;">
                            <img src="{avatar_url}" alt="{login}" style="width: 80px; height: 80px; border-radius: 50%; margin-bottom: 5px;" />
                            <div>{login}</div>
                            <div style="font-size: 0.8em; color: #666;">{contributions} commit{"s" if contributions != 1 else ""}</div>
                        </a>
                    </div>
                    ''', 
                    format='html'))
                    
                container.append(contributor_div)
                
            return [container]
            
        except Exception as e:
            warning_node = nodes.warning()
            warning_node += nodes.paragraph(text=f"Error getting GitHub contributors: {e}")
            return [warning_node]


def setup(app):
    """
    Set up the Sphinx extension.
    """
    app.add_directive('github-contributors', GithubContributorsDirective)
    
    return {
        'version': '0.1',
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    } 