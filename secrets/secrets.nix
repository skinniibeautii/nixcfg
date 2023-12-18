let
  tcurdt = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA2CLOzyXcqk4uo6hCkkQAtozJCebA/Dh4ps6Vr2GVNTC7j7nF5HuT+penp/Y9yPAuTorxunmFn7BPwZggzopEgfmUQ4gf0CysTwPQMxt9yK3ZHpxgkGoJyR0n91OdPAbukqwWZHYxGGxvHNoap59kobUrIImIa97gKxW+IVKwL9iyWXyqonRpue1mf1N1ioDtPLS1yvzf4Jo7aDND+4I/34X6436VwZItUwzvhFcuNh/gQmvKpmVjD+ED2Q/yRtGq0EzsPfrDZg1ZKV5V1cT/3w7QtYFcZB9+AQxq88jVRcIlf3K45kpmbsWVfBFN6ND+NeZK1mlp/3TV8C6dNVqU2w== tcurdt@shodan.local";
  users = [ tcurdt ];

  utm = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDB7xeeK1RxGKdNXeERy+vYRM0lurBYKFIJXdqBCfN7Qs0XxuRN3TIOyHdcsCHMYye/FwIpVqelaZ8zaQQ174yS23eatsp7Obd8EYLkhQhQawhi78F/T1OtiSx6MtG/a5LJzLT5tFAUviTxQoB4SSJunLeyQTfGPyj3tlEL4Kqx3xbxEWXTxDFEOT3jCIcYzIZPDA6Ar2+YcwvAuiMI3O3bgxXKsCXM27F5tsN+wMdmFVY+RV3RSgSL96qA0X8/ANPlsNG0ehCyTIvAeu83s5Jm/o4qTStm618ZaoyubOn7ruoSV3PlAK0HbWZThWEeOFfRrcTKxTYDgMTf+7RrhwHyU5x0Po+zHxJRasUHnF+A8GWgKmVbA6xzZ6Rg0mkyah5H9fZ71fSi25knMgOfwFFgvJgq04tB8WvJqCyv4yu3Vkdn/Ik7rcgc28dnjXKZd1LuwWBSDjGuVBjg7cH4ukvOZijOhj3FAWDBM0UWDwblwEiz3BnJuLCYfJH2f7GQF2M= root@debian12arm";
  systems = [ utm ];
in
{
  "utm.age".publicKeys = [ tcurdt utm ];
}