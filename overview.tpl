<%
import datetime
%>\
Host overview
===================

% for hostname, host in sorted(hosts.items()):
${hostname.capitalize()}
-------------------

* `ansible_facts.system`：`${host['ansible_facts'].get('ansible_system', '')}`
* `ansible_facts.os_family`：`${host['ansible_facts'].get('ansible_os_family', '')}`
* `ansible_facts.distribution`：`${host['ansible_facts'].get('ansible_distribution', '')}`
* `ansible_facts.distribution_major_version`：`${host['ansible_facts'].get('ansible_distribution_major_version', '')}`
* `ansible_facts.ansible_distribution_release`：`${host['ansible_facts'].get('ansible_distribution_release', '')}`
* `ansible_facts.pkg_mgr`：`${host['ansible_facts'].get('ansible_pkg_mgr', '')}`
* `ansible_facts.architecture`：`${host['ansible_facts'].get('ansible_architecture', '')}`
* `ansible_facts.kernel`：`${host['ansible_facts'].get('ansible_kernel', '')}`

% endfor
