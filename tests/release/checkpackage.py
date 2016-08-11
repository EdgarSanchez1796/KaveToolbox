##############################################################################
#
# Copyright 2016 KPMG Advisory N.V. (unless otherwise stated)
#
# Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
##############################################################################
import base
import unittest


class TestKTBPackaging(unittest.TestCase):

    def runTest(self):
        """
        Check that the packaging script works
        """
        import os
        import glob
        builddir = os.path.dirname(__file__) + '/../../build'
        if os.path.exists(builddir):
            os.system('rm -rf ' + builddir)
        os.system(os.path.dirname(__file__) + '/../../package/package.sh')
        self.assertTrue(os.path.exists(builddir))
        self.assertTrue(len(glob.glob(builddir + '/kavetoolbox-installer*.sh')))
        self.assertTrue(len(glob.glob(builddir + '/kavetoolbox-*.tar.gz')))
        if os.path.exists(builddir):
            os.system('rm -rf ' + builddir)


if __name__ == "__main__":
    import sys

    verbose = False
    if "--verbose" in sys.argv:
        verbose = True
        sys.argv = [s for s in sys.argv if s != "--verbose"]
    test1 = TestKTBPackaging()
    test1.debug = verbose
    suite = unittest.TestSuite()
    suite.addTest(test1)
    base.run(suite)